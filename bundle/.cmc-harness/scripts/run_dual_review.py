from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path


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


def require_command(name: str) -> str:
    path = shutil.which(name)
    if path is None:
        raise RuntimeError(f"PATH에서 필수 명령을 찾을 수 없습니다: {name}")
    return path


def run_command(command: list[str], cwd: Path) -> str:
    result = subprocess.run(
        command,
        cwd=str(cwd),
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=600,
        check=False,
    )
    output = (result.stdout or "").strip()
    error = (result.stderr or "").strip()
    if not output and error:
        output = error
    return output


def main() -> int:
    args = parse_args()
    if not args.prompt and not args.prompt_file:
        print("--prompt 또는 --prompt-file 중 하나를 제공해야 합니다.", file=sys.stderr)
        return 2

    repo_root = Path.cwd().resolve()
    harness_root = repo_root / ".cmc-harness"
    prompts_dir = harness_root / "prompts"

    user_prompt = args.prompt.strip() if args.prompt else load_text(Path(args.prompt_file))
    claude_prefix = load_text(prompts_dir / "claude_lead_review.md")
    gemini_prefix = load_text(prompts_dir / "gemini_skeptical_review.md")

    workspace = Path(args.workspace).resolve()
    output_root = Path(args.output_dir).resolve()
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    run_dir = output_root / timestamp
    run_dir.mkdir(parents=True, exist_ok=True)

    claude_bin = require_command("claude")
    gemini_bin = require_command("gemini")

    claude_prompt = f"{claude_prefix}\n\n---\n\n{user_prompt}"
    gemini_prompt = f"{gemini_prefix}\n\n---\n\n{user_prompt}"

    claude_output = run_command([claude_bin, "-p", claude_prompt], cwd=workspace)
    gemini_output = run_command(
        [gemini_bin, "-p", gemini_prompt, "--output-format", "text"],
        cwd=workspace,
    )

    (run_dir / "claude.md").write_text(claude_output + "\n", encoding="utf-8")
    (run_dir / "gemini.md").write_text(gemini_output + "\n", encoding="utf-8")
    summary = {
        "timestamp": timestamp,
        "workspace": str(workspace),
        "claude_file": str(run_dir / "claude.md"),
        "gemini_file": str(run_dir / "gemini.md"),
    }
    (run_dir / "summary.json").write_text(
        json.dumps(summary, indent=2), encoding="utf-8"
    )

    print(f"리뷰 결과를 저장했습니다: {run_dir}")
    print(f"- Claude: {run_dir / 'claude.md'}")
    print(f"- Gemini: {run_dir / 'gemini.md'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
