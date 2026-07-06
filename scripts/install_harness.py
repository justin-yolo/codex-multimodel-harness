from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="대상 레포지토리에 CMC 하네스 번들을 설치합니다."
    )
    parser.add_argument(
        "--target",
        required=True,
        help="하네스 파일을 설치할 대상 레포 루트 경로",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="기존 파일이 있어도 중단하지 않고 덮어쓰기",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="실제 파일을 쓰지 않고 예정 작업만 출력",
    )
    return parser.parse_args()


def iter_bundle_files(bundle_root: Path) -> list[tuple[Path, Path]]:
    items: list[tuple[Path, Path]] = []
    for src in sorted(bundle_root.rglob("*")):
        if "__pycache__" in src.parts or src.suffix == ".pyc":
            continue
        if src.is_file():
            items.append((src, src.relative_to(bundle_root)))
    return items


def main() -> int:
    args = parse_args()
    repo_root = Path(args.target).expanduser().resolve()
    bundle_root = Path(__file__).resolve().parents[1] / "bundle"

    target_exists = repo_root.exists()
    if not target_exists and not args.dry_run:
        print(f"대상 레포가 존재하지 않습니다: {repo_root}", file=sys.stderr)
        return 1

    file_pairs = iter_bundle_files(bundle_root)
    conflicts: list[Path] = []
    if target_exists:
        for src, rel in file_pairs:
            dst = repo_root / rel
            if dst.exists():
                conflicts.append(rel)

    if conflicts and not args.force and not args.dry_run:
        print("--force 없이 기존 파일을 덮어쓸 수 없어 중단합니다:", file=sys.stderr)
        for rel in conflicts:
            print(f"  - {rel}", file=sys.stderr)
        return 2

    conflict_set = set(conflicts)
    if args.dry_run:
        if not target_exists:
            print(f"참고: 대상 경로가 아직 존재하지 않습니다: {repo_root}")
            print("실제 설치 전에는 대상 프로젝트 디렉터리를 먼저 만들어야 합니다.")
        if conflicts and not args.force:
            print("충돌 예정: 다음 기존 파일은 실제 설치 때 --force가 필요합니다:")
            for rel in conflicts:
                print(f"  - {rel}")

    for src, rel in file_pairs:
        dst = repo_root / rel
        if args.dry_run:
            suffix = " (--force 필요)" if rel in conflict_set and not args.force else ""
            print(f"설치 예정: {rel}{suffix}")
            continue
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        print(f"설치 완료: {rel}")

    if not args.dry_run and not (repo_root / ".git").exists():
        print("경고: 대상 경로가 git 레포로 보이지 않지만 설치는 완료했습니다.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
