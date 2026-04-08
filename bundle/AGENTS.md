# AGENTS.md

## Scope
이 지침은 이 파일이 있는 레포 루트에 적용됩니다.

## Session Start
1. 새 세션마다 먼저 `HANDOFF.md`를 읽습니다.
2. 로컬 도구 설치 상태가 불확실하면 `python .cmc-harness/scripts/doctor.py`를 실행합니다.

## Mandatory Workflow
1. 실질적인 작업 전에, 환경이 지원하면 최소 하나의 관련 로컬 스킬을 먼저 적용합니다.
2. 맞는 스킬이 없으면 그 사실을 짧게 밝히고 가장 안전한 대안 절차를 사용합니다.
3. 사소하지 않은 작업은, 플랫폼이 지원하면 초반에 최소 하나의 서브에이전트를 띄웁니다.
4. 첫 진행 업데이트에서는 어떤 스킬 또는 대안을 쓰는지와 서브에이전트 역할을 명시합니다.
5. 모델 리뷰 전에 반드시 로컬 근거를 먼저 확보합니다. 직접 확인, 테스트, 로그 대신 모델 의견으로 대체하지 않습니다.

## Multi-Model Review Policy
1. 사소하지 않은 작업은 가능하면 로컬 Claude CLI와 Gemini CLI를 모두 사용합니다.
2. Claude는 설계 판단, 디버깅 판단, 최종 추천 품질 측면의 리드 리뷰어로 둡니다.
3. Gemini는 가정을 흔들고 빠진 리스크를 드러내는 독립적인 비판자 역할로 둡니다.
4. Claude와 Gemini가 충돌하면, 먼저 로컬 근거를 우선하고, 직접 근거가 반박하지 않는 한 Claude 판단을 기본 tie-breaker로 둡니다.
5. 최종 답변 전에는 Claude review, Gemini review, local verification 완료 여부를 기록합니다.

## Workspace Collaboration Defaults
- 사소하지 않은 작업의 기본 순서는 `관련 스킬 -> 초반 서브에이전트 -> 로컬 근거 수집 -> Claude review -> Gemini review -> 최종 종합`입니다.
- `HANDOFF.md`를 현재 프로젝트 상태의 기준 문서로 유지합니다.
- 가능하면 `python .cmc-harness/scripts/run_dual_review.py`를 사용해 Claude/Gemini 리뷰를 반복 가능하게 남깁니다.

## Current Research / Project Frame
- `HANDOFF.md`를 현재 목표, 블로커, 보존 산출물을 담는 살아있는 상태 문서로 사용합니다.
- 현재 상태 문서라고 명시되지 않은 오래된 문서는 역사 기록으로 취급합니다.
