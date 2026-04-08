# Codex 멀티모델 하네스

이 저장소는 Codex를 주 실행자로 쓰면서, 로컬 Claude CLI와 Gemini CLI를
구조적으로 협업 리뷰어로 붙이고 싶은 사용자를 위한 포터블 스캐폴드입니다.

Codex 데스크톱의 숨겨진 시스템 프롬프트나 내부 런타임을 복제해 주는 것은
아닙니다. 대신 아래를 포함한 재사용 가능한 레포 구조를 제공합니다.

- Codex, Claude, Gemini용 레포 정책 파일
- 단일/이중 모델 리뷰를 위한 포터블 PowerShell 및 shell 스크립트
- 다른 사용자를 위한 설정 문서
- Gemini를 비판적 리뷰어, Claude를 리드 리뷰어로 두는 기본 협업 루틴

## 이 하네스의 목적

다른 Codex 사용자가 이 레포를 클론하거나, 각 프로젝트에 이 구조를 넣었을 때
익숙한 멀티모델 협업 패턴으로 바로 작업할 수 있게 만드는 것이 목적입니다.

기본 흐름은 아래와 같습니다.

1. Codex가 로컬 컨텍스트를 읽고 근거를 수집합니다.
2. Codex가 작업이 사소한지 아닌지 판단합니다.
3. 사소하지 않은 작업이면 Gemini로 먼저 비판적 검토를 받습니다.
4. 중요도가 높거나 판단 품질이 특히 중요하면 Claude로 리드 리뷰를 받습니다.
5. 최종 결정과 실제 수정은 다시 Codex가 종합합니다.

## 이 하네스가 하지 않는 것

- Claude CLI나 Gemini CLI를 대신 설치하지 않습니다.
- API 키나 로그인 상태를 제공하지 않습니다.
- Codex 시스템 프롬프트나 숨겨진 도구를 복제하지 않습니다.
- 모든 머신에서 완전히 동일한 동작을 보장하지 않습니다.

## 주요 파일

- `AGENTS.md`: Codex용 작업 정책
- `CLAUDE.md`: Claude CLI 리뷰 정책
- `GEMINI.md`: Gemini CLI 리뷰 정책
- `docs/setup.md`: 다른 사용자를 위한 설정 가이드
- `docs/workflow.md`: 권장 협업 순서
- `prompts/review_request_template.md`: 재사용 가능한 리뷰 요청 템플릿
- `scripts/`: 환경 점검, 모델 리뷰, 스모크 테스트 스크립트
- `bundle/`: 다른 프로젝트 루트에 복사할 수 있는 최소 하네스 번들

## 다른 프로젝트에 설치

이 하네스는 현재 저장소 안에서 바로 시험할 수도 있고, 다른 프로젝트 루트에
정책 파일과 스크립트만 옮겨서 재사용할 수도 있습니다.

가장 간단한 방법은 설치 스크립트를 사용하는 것입니다.

```powershell
python .\harness\scripts\install_harness.py --target C:\path\to\your-project --dry-run
python .\harness\scripts\install_harness.py --target C:\path\to\your-project
```

macOS/Linux에서는:

```bash
python3 ./harness/scripts/install_harness.py --target /path/to/your-project --dry-run
python3 ./harness/scripts/install_harness.py --target /path/to/your-project
```

이미 대상 프로젝트에 같은 파일이 있다면 `--force`를 붙여 덮어쓸 수 있습니다.

설치 스크립트는 `bundle/` 아래의 최소 파일만 대상 프로젝트 루트로 복사합니다.
직접 복사하고 싶다면 `harness/bundle/` 내용을 프로젝트 루트에 수동으로 옮겨도 됩니다.

## 이 저장소에서 바로 테스트

아래 명령은 저장소 루트 기준으로 적었습니다. `harness/` 디렉터리 안으로 들어가서
실행한다면 앞의 `harness/` 경로 접두사만 빼면 됩니다.

1. `claude`와 `gemini`가 `PATH`에 있어야 합니다.
2. 환경 점검:

```powershell
powershell -ExecutionPolicy Bypass -File .\harness\scripts\check_multimodel_env.ps1
```

macOS/Linux에서는:

```bash
sh ./harness/scripts/check_multimodel_env.sh
```

3. 이 레포를 Codex로 엽니다.
4. 터미널에서 이중 리뷰를 돌리고 싶다면:

```powershell
powershell -ExecutionPolicy Bypass -File .\harness\scripts\run_dual_review.ps1 -PromptFile .\harness\prompts\review_request_template.md
```

macOS/Linux에서는:

```bash
sh ./harness/scripts/run_dual_review.sh --prompt-file ./harness/prompts/review_request_template.md
```

5. 실제 모델 호출까지 보는 스모크 테스트:

```powershell
powershell -ExecutionPolicy Bypass -File .\harness\scripts\smoke_test_reviews.ps1
```

## 휴대성 메모

- 스크립트는 머신별 절대경로 대신 `PATH`에서 `claude`와 `gemini`를 찾습니다.
- 기본 모델은 `HARNESS_CLAUDE_MODEL`, `HARNESS_GEMINI_MODEL` 환경변수로 바꿀 수 있습니다.
- 정책 파일은 가능한 한 레포 로컬 상대경로를 기준으로 작성되어 있습니다.
- 팀의 역할 분담을 바꾸려면 `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`를 함께 수정해 일관성을 유지하는 것이 좋습니다.
