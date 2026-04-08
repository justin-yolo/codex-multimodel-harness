# 설정 가이드

## 목표

다른 Codex 사용자가 최소한의 로컬 수정만으로 동일한 Codex+Gemini+Claude
협업 패턴을 재현할 수 있게 이 레포를 준비하는 것이 목표입니다.

## 준비물

- Codex 사용 가능 환경
- Python 3.x
- 설치 및 인증된 Claude CLI
- 설치 및 인증된 Gemini CLI
- PowerShell 7 또는 Windows PowerShell

## 다른 프로젝트에 설치

현재 저장소 전체를 그대로 들고 가지 않고도, 설치 스크립트로 최소 번들을
다른 프로젝트 루트에 복사할 수 있습니다.

저장소 루트에서 실행한다면:

```powershell
python .\scripts\install_harness.py --target C:\path\to\your-project --dry-run
python .\scripts\install_harness.py --target C:\path\to\your-project
```

macOS/Linux에서는:

```bash
python3 ./scripts/install_harness.py --target /path/to/your-project --dry-run
python3 ./scripts/install_harness.py --target /path/to/your-project
```

기존 파일이 있을 때 덮어쓰려면 `--force`를 붙입니다.
설치 스크립트는 `bundle/` 아래 파일만 대상 프로젝트 루트로 복사합니다.

## 환경 점검

다음 명령을 실행합니다.

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check_multimodel_env.ps1
```

기대 결과:

- `claude`가 `PATH`에서 잡힘
- `gemini`가 `PATH`에서 잡힘
- 두 CLI 모두 버전 출력에서 바로 죽지 않음

그 다음 실제 호출까지 보는 스모크 테스트를 실행합니다.

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\smoke_test_reviews.ps1
```

macOS/Linux에서는:

```bash
sh ./scripts/smoke_test_reviews.sh
```

## Gemini 경고 메모

일부 로컬 Gemini 설치는 사용자별 extension 경고를 출력할 수 있습니다.
요청한 리뷰 결과가 정상적으로 반환된다면, 그 경고 자체는 이 레포 문제로
보지 않아도 됩니다.

## 권장 레포 관례

- `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`는 레포 루트에 둡니다.
- 헬퍼 스크립트는 `scripts/` 아래에 둡니다.
- 재사용 가능한 프롬프트는 `prompts/` 아래에 둡니다.
- 머신별 메모는 커밋되는 정책 파일에 넣지 않습니다.

## 인증 메모

이 하네스는 각 사용자가 자기 로컬 Claude/Gemini CLI를 직접 인증한다고
가정합니다. 레포 안에 API 키나 개인 로그인 산출물을 넣으면 안 됩니다.

## 모델 오버라이드

지역 또는 조직 환경 때문에 기본 모델을 못 쓰는 경우, 헬퍼 실행 전에
환경변수로 바꿀 수 있습니다.

```powershell
$env:HARNESS_CLAUDE_MODEL = "your-claude-model"
$env:HARNESS_GEMINI_MODEL = "your-gemini-model"
```
