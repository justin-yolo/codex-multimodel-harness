from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Union


@dataclass
class ModelResult:
    name: str
    exit_code: int
    status: str
    stdout: str
    stderr: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="같은 리뷰 프롬프트로 Claude CLI와 Gemini CLI를 모두 실행합니다."
    )
    parser.add_argument(
        "--prompt",
        help="바로 전달할 인라인 프롬프트",
    )
    parser.add_argument(
        "--prompt-file",
        help="작업/근거 프롬프트가 들어 있는 파일 경로",
    )
    parser.add_argument(
        "--workspace",
        default=".",
        help="두 CLI에 공통으로 전달할 작업 디렉터리",
    )
    parser.add_argument(
        "--output-dir",
        default=".cmc-harness/reviews",
        help="타임스탬프별 리뷰 결과를 저장할 디렉터리",
    )
    return parser.parse_args()


def load_text(path: Path) -> str:
    return path.read_text(encoding="utf-8").strip()


def resolve_path(value: str) -> Path:
    path = Path(value).expanduser()
    if not path.is_absolute():
        path = Path.cwd() / path
    return path.resolve()


def coerce_output(value: Union[str, bytes, None]) -> str:
    if value is None:
        return ""
    if isinstance(value, bytes):
        return value.decode("utf-8", errors="replace")
    return value


def run_command(
    name: str,
    args: list[str],
    cwd: Path,
    input_text: Union[str, None] = None,
) -> ModelResult:
    command_path = shutil.which(name)
    if command_path is None:
        return ModelResult(
            name=name,
            exit_code=127,
            status="failed",
            stdout="",
            stderr=f"Required command not found on PATH: {name}",
        )

    try:
        result = subprocess.run(
            [command_path, *args],
            cwd=str(cwd),
            input=input_text,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=600,
            check=False,
        )
    except subprocess.TimeoutExpired as exc:
        stderr = coerce_output(exc.stderr).strip()
        timeout_message = f"Command timed out after {exc.timeout} seconds."
        if stderr:
            stderr = f"{stderr}\n{timeout_message}"
        else:
            stderr = timeout_message
        return ModelResult(
            name=name,
            exit_code=124,
            status="failed",
            stdout=coerce_output(exc.stdout).strip(),
            stderr=stderr,
        )
    except OSError as exc:
        return ModelResult(
            name=name,
            exit_code=127,
            status="failed",
            stdout="",
            stderr=str(exc),
        )
    except ValueError as exc:
        return ModelResult(
            name=name,
            exit_code=1,
            status="failed",
            stdout="",
            stderr=str(exc),
        )

    return ModelResult(
        name=name,
        exit_code=result.returncode,
        status="ok" if result.returncode == 0 else "failed",
        stdout=(result.stdout or "").strip(),
        stderr=(result.stderr or "").strip(),
    )


def render_model_output(result: ModelResult) -> str:
    label = result.name.capitalize()
    parts = []
    if result.stdout:
        parts.append(result.stdout)
    else:
        parts.append(f"# {label} output\n\n(no stdout captured)")

    parts.extend(
        [
            "",
            "---",
            f"{label} status: {result.status}",
            f"{label} exit code: {result.exit_code}",
        ]
    )
    if result.stderr:
        parts.extend(["", "## stderr", "", "```text", result.stderr, "```"])
    return "\n".join(parts).rstrip() + "\n"


def first_nonempty_line(value: str) -> str:
    for line in value.splitlines():
        line = line.strip()
        if line:
            return line
    return ""


def failure_detail(result: ModelResult) -> str:
    detail = first_nonempty_line(result.stderr) or first_nonempty_line(result.stdout)
    if not detail:
        return "no output captured"
    if len(detail) > 300:
        return detail[:297] + "..."
    return detail


def summarize_model(result: ModelResult, output_file: Path) -> dict[str, object]:
    return {
        "status": result.status,
        "exit_code": result.exit_code,
        "output_file": str(output_file),
        "stdout_length": len(result.stdout),
        "stderr_length": len(result.stderr),
    }


def main() -> int:
    args = parse_args()
    if not args.prompt and not args.prompt_file:
        print("--prompt 또는 --prompt-file 중 하나를 제공해야 합니다.", file=sys.stderr)
        return 2

    harness_root = Path(__file__).resolve().parents[1]
    prompts_dir = harness_root / "prompts"

    user_prompt = (
        args.prompt.strip()
        if args.prompt
        else load_text(resolve_path(args.prompt_file))
    )
    claude_prefix = load_text(prompts_dir / "claude_lead_review.md")
    gemini_prefix = load_text(prompts_dir / "gemini_skeptical_review.md")

    workspace = resolve_path(args.workspace)
    output_root = resolve_path(args.output_dir)
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    run_dir = output_root / timestamp
    run_dir.mkdir(parents=True, exist_ok=True)

    claude_prompt = f"{claude_prefix}\n\n---\n\n{user_prompt}"
    gemini_prompt = f"{gemini_prefix}\n\n---\n\n{user_prompt}"

    claude_result = run_command(
        "claude",
        ["-p"],
        cwd=workspace,
        input_text=claude_prompt,
    )
    gemini_result = run_command(
        "gemini",
        ["--prompt", " ", "--output-format", "text"],
        cwd=workspace,
        input_text=gemini_prompt,
    )

    claude_file = run_dir / "claude.md"
    gemini_file = run_dir / "gemini.md"
    claude_file.write_text(render_model_output(claude_result), encoding="utf-8")
    gemini_file.write_text(render_model_output(gemini_result), encoding="utf-8")

    summary = {
        "timestamp": timestamp,
        "workspace": str(workspace),
        "claude_file": str(claude_file),
        "gemini_file": str(gemini_file),
        "models": {
            "claude": summarize_model(claude_result, claude_file),
            "gemini": summarize_model(gemini_result, gemini_file),
        },
    }
    (run_dir / "summary.json").write_text(
        json.dumps(summary, indent=2), encoding="utf-8"
    )

    print(f"리뷰 결과를 저장했습니다: {run_dir}")
    print(f"- Claude: {claude_file}")
    print(f"- Gemini: {gemini_file}")

    failed_results = [
        result for result in (claude_result, gemini_result) if result.status != "ok"
    ]
    if failed_results:
        print("", file=sys.stderr)
        print("리뷰 명령 실패:", file=sys.stderr)
        for result in failed_results:
            print(
                f"- {result.name.capitalize()}: exit {result.exit_code}; "
                f"{failure_detail(result)}",
                file=sys.stderr,
            )
        print(f"전체 로그: {run_dir}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
