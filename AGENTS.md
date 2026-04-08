# AGENTS.md

## Scope

이 지침은 이 레포 전체에 적용됩니다.

## Session Start

1. 먼저 `README.md`와 `docs/workflow.md`를 읽습니다.
2. 작업이 멀티모델 리뷰에 의존하면 `scripts/check_multimodel_env.ps1`로 `claude`와 `gemini` 가용성을 확인합니다.

## Core Goal

이 레포는 Codex 우선 협업 하네스입니다.

Codex가 실제 실행 런타임입니다.  
Claude와 Gemini는 Codex가 필요할 때 호출하는 외부 리뷰 런타임입니다.

## Workflow Defaults

1. 실질적인 작업은 가능하면 먼저 관련 로컬 스킬을 거칩니다.
2. 다른 모델 리뷰를 부르기 전에 로컬 근거를 먼저 수집합니다.
3. 대부분의 사소하지 않은 작업은 Gemini로 빠른 비판적 검토를 먼저 받습니다.
4. 설계 판단, 고위험 변경, 최종 판단 품질이 중요한 일은 Claude까지 올립니다.
5. 가능한 환경이라면 초반에 병렬 근거 수집을 선호합니다.
6. 중요한 결론을 마무리하기 전에는 local verification, Gemini review, Claude review 완료 여부를 명시합니다.

## Multi-Model Policy

- Gemini는 일상적인 비판적 검토를 위한 기본 2차 런타임입니다.
- Claude는 아키텍처, 디버깅 판단, 최종 추천 품질에서 리드 리뷰어입니다.
- Claude와 Gemini가 다르면 먼저 직접 로컬 근거를 우선합니다.
- 로컬 근거가 불완전하면 더 좁고 보수적인 결론을 기본값으로 둡니다.
- 로컬 컨텍스트만으로 끝낼 수 있는 사소한 작업에는 외부 리뷰 모델을 부르지 않습니다.

## Review Helpers

터미널에서 리뷰가 필요하면 아래 레포 로컬 헬퍼를 사용합니다.

- `scripts/run_gemini_review.ps1`
- `scripts/run_claude_review.ps1`
- `scripts/run_dual_review.ps1`

## Output Expectations

- 판단은 파일, 명령, 설정, 메트릭 같은 구체 근거에 연결합니다.
- 모호한 "괜찮아 보인다"식 요약은 피합니다.
- 짧은 verdict와 핵심 이유를 우선합니다.
