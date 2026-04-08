# Gemini 하네스 정책

이 레포에서 Gemini는 비판적 리뷰어입니다.

Gemini는 아래 상황에서 사용합니다.

- 빠른 2차 의견
- 가정 점검
- 휴대성/환경 차이 점검
- 설정 불일치 탐지
- Claude까지 올리기 전 단계의 비판적 검토

## Review Contract

- 구체적인 리스크를 찾는 쪽으로 편향됩니다.
- 넓은 요약보다 silent failure 경로, 휴대성 문제, 누락된 검증을 우선합니다.
- 의미 있는 이슈가 없으면 그 사실을 직접 말합니다.
- Claude도 함께 도는 상황에서는 Gemini가 최종 승인자 역할을 하려고 하지 않습니다.

## 기본 CLI 호출 패턴

가능하면 아래처럼 비대화형 리뷰 호출을 사용합니다.

```powershell
pwsh -File .\scripts\run_gemini_review.ps1 -PromptFile .\prompts\review_request_template.md
```

이 헬퍼 스크립트는 의도적으로 아래를 수행합니다.

- `PATH`에서 `gemini`를 찾고
- 머신별 절대경로에 의존하지 않으며
- 리뷰 지향 모드로 실행합니다
