# Codex Multimodel Harness

Codex를 실행 주체로 두고, 필요할 때 Claude CLI와 Gemini CLI를 리뷰어로
호출하는 작은 프로젝트 템플릿입니다.

정책 파일, 리뷰 스크립트, 복사용 `bundle/`을 묶어 다른 레포에도 Codex 중심의
멀티모델 리뷰 루틴을 옮길 수 있게 합니다.

> Codex 데스크톱의 내부 프롬프트나 숨겨진 도구를 복제하지 않습니다. Claude와
> Gemini CLI 설치, 로그인, API 키도 각 사용자가 직접 준비해야 합니다.

## 30초 요약

- 내 프로젝트에 `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.cmc-harness/`를 복사합니다.
- Codex는 파일 수정, 명령 실행, 검증, 최종 판단을 맡습니다.
- Gemini는 빠른 비판적 리뷰어로 사용합니다.
- Claude는 설계, 디버깅, 고위험 판단의 리드 리뷰어로 사용합니다.
- 실패 로그는 숨기지 않고 남겨서 CLI 인증/모델 문제와 하네스 문제를 구분합니다.

## Quick Start

### Windows

```powershell
git clone https://github.com/justin-yolo/codex-multimodel-harness.git
cd codex-multimodel-harness

powershell -ExecutionPolicy Bypass -File .\scripts\check_multimodel_env.ps1

python .\scripts\install_harness.py --target C:\path\to\your-project --dry-run
python .\scripts\install_harness.py --target C:\path\to\your-project
```

### macOS/Linux

```bash
git clone https://github.com/justin-yolo/codex-multimodel-harness.git
cd codex-multimodel-harness

sh ./scripts/check_multimodel_env.sh

python3 ./scripts/install_harness.py --target /path/to/your-project --dry-run
python3 ./scripts/install_harness.py --target /path/to/your-project
```

실제 설치에서는 대상 프로젝트 디렉터리가 이미 존재해야 합니다. `--dry-run`은
대상 디렉터리를 만들기 전에도 실행할 수 있으며, 복사 예정 파일과 충돌 파일을
먼저 확인하는 용도입니다.

기존 파일을 덮어써야 한다면 설치 명령에 `--force`를 추가합니다.

## 설치 후 사용

아래 명령은 하네스를 설치한 대상 프로젝트 루트에서 실행합니다.

```powershell
python .cmc-harness/scripts/doctor.py
python .cmc-harness/scripts/run_dual_review.py --prompt-file .cmc-harness/prompts/evidence_template.md
```

간단한 인라인 프롬프트로도 실행할 수 있습니다.

```powershell
python .cmc-harness/scripts/run_dual_review.py --prompt "이 레포 구조를 리뷰해줘"
```

리뷰 결과는 기본적으로 `.cmc-harness/reviews/` 아래에 저장됩니다. 이 디렉터리는
번들에 포함된 `.gitignore`로 커밋되지 않도록 보호됩니다.

## 작동 방식

| 역할 | 기본 책임 |
| --- | --- |
| Codex | 로컬 근거 수집, 파일 수정, 명령 실행, 최종 종합 |
| Gemini | 빠른 비판적 리뷰, 가정 점검, 휴대성 리스크 탐지 |
| Claude | 설계 판단, 복잡한 디버깅, 고위험 변경의 리드 리뷰 |

기본 흐름은 단순합니다.

```text
Codex가 근거 수집 -> Gemini가 비판적 검토 -> 필요하면 Claude가 리드 리뷰 -> Codex가 최종 수정/판단
```

작은 작업은 Codex만으로 끝낼 수 있습니다. 설정 리뷰나 빠른 2차 의견은 Gemini를
먼저 사용하고, 설계 변경이나 중요한 디버깅처럼 판단 리스크가 큰 작업은 Claude까지
올리는 흐름을 권장합니다.

## 포함되는 파일

설치 스크립트는 `bundle/` 아래의 최소 파일만 대상 프로젝트 루트로 복사합니다.

| 경로 | 용도 |
| --- | --- |
| `AGENTS.md` | Codex 작업 정책 |
| `CLAUDE.md` | Claude CLI 리뷰 정책 |
| `GEMINI.md` | Gemini CLI 리뷰 정책 |
| `HANDOFF.md` | 작업 인수인계 템플릿 |
| `.cmc-harness/scripts/doctor.py` | 대상 프로젝트의 하네스 상태 점검 |
| `.cmc-harness/scripts/run_dual_review.py` | Claude/Gemini 리뷰 실행 및 결과 저장 |
| `.cmc-harness/prompts/` | 재사용 가능한 리뷰 프롬프트 |

이 저장소의 루트 `scripts/`는 하네스 자체를 테스트하고 관리하기 위한 헬퍼입니다.
설치된 프로젝트에서는 `.cmc-harness/scripts/`를 주로 사용합니다.

## 이 저장소에서 바로 테스트

하네스 자체를 이 저장소에서 시험하려면 아래 명령을 사용합니다.

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run_dual_review.ps1 -PromptFile .\prompts\review_request_template.md
powershell -ExecutionPolicy Bypass -File .\scripts\smoke_test_reviews.ps1
```

macOS/Linux에서는:

```bash
sh ./scripts/run_dual_review.sh --prompt-file ./prompts/review_request_template.md
sh ./scripts/smoke_test_reviews.sh
```

`smoke_test_reviews`는 실제 Claude/Gemini 호출까지 확인합니다. 인증 또는 모델 오류가
나오면 먼저 각 CLI가 단독으로 정상 호출되는지 확인하세요.

## Troubleshooting

| 증상 | 확인할 것 |
| --- | --- |
| `claude` 또는 `gemini`를 찾지 못함 | CLI가 설치되어 있고 `PATH`에 잡히는지 확인 |
| 인증 또는 모델 오류 | 각 CLI에서 단독 호출이 되는지 확인 |
| 특정 모델을 사용할 수 없음 | `HARNESS_CLAUDE_MODEL`, `HARNESS_GEMINI_MODEL` 환경변수로 모델명 변경 |
| 설치 중 기존 파일 충돌 | 먼저 `--dry-run`으로 확인한 뒤 필요하면 `--force` 사용 |
| 리뷰 결과가 커밋될까 걱정됨 | `.cmc-harness/reviews/`는 번들 `.gitignore`로 제외됨 |

예시:

```powershell
$env:HARNESS_CLAUDE_MODEL = "your-claude-model"
$env:HARNESS_GEMINI_MODEL = "your-gemini-model"
```

## 자세한 문서

- `docs/setup.md`: 설치, 인증, 환경 점검 가이드
- `docs/workflow.md`: Codex, Gemini, Claude 역할 분담과 의사결정 기준
- `prompts/review_request_template.md`: 직접 리뷰 요청을 만들 때 쓰는 템플릿

## 주의사항

- Claude CLI나 Gemini CLI를 대신 설치하지 않습니다.
- API 키나 로그인 상태를 제공하지 않습니다.
- Codex 시스템 프롬프트나 숨겨진 도구를 복제하지 않습니다.
- 모든 머신에서 완전히 동일한 동작을 보장하지 않습니다.
