from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path


def check_command(name: str) -> tuple[bool, str]:
    path = shutil.which(name)
    if not path:
        return False, "찾을 수 없음"
    try:
        result = subprocess.run(
            [path, "--version"],
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=15,
            check=False,
        )
        text = (result.stdout or result.stderr or "").strip()
        if not text:
            text = f"경로 확인: {path}"
        return True, text.splitlines()[0]
    except Exception as exc:  # pragma: no cover - defensive
        return True, f"경로 확인: {path}, 버전 확인 실패: {exc}"


def main() -> int:
    repo_root = Path.cwd()
    required_files = [
        repo_root / "AGENTS.md",
        repo_root / "HANDOFF.md",
        repo_root / "CLAUDE.md",
        repo_root / "GEMINI.md",
    ]

    print("CMC Harness Doctor")
    print(f"레포 루트: {repo_root}")
    print()

    missing_files = [path.name for path in required_files if not path.exists()]
    if missing_files:
        print("누락된 레포 파일:")
        for name in missing_files:
            print(f"  - {name}")
    else:
        print("레포 파일: OK")

    for command in ("python", "claude", "gemini"):
        ok, detail = check_command(command)
        status = "OK" if ok else "MISSING"
        print(f"{command:7} {status:7} {detail}")

    return 1 if missing_files else 0


if __name__ == "__main__":
    raise SystemExit(main())
