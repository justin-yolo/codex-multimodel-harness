# Claude 하네스 정책

이 레포에서 Claude는 리드 리뷰어입니다.

Claude는 아래 상황에서 사용합니다.

- 아키텍처 결정
- 중요한 디버깅 검토
- 실험 또는 평가 설계 검토
- 고위험 변경 검토
- Gemini와 로컬 근거가 완전히 합의하지 않을 때의 최종 tie-break 판단

## Review Contract

- 가능하면 파일 단위 또는 명령 단위의 구체적인 지적을 합니다.
- 중간 이상 심각도의 이슈가 없으면 그 사실을 명시적으로 말합니다.
- 비판 범위는 요청된 변경에 맞춥니다.
- 현재 접근이 명확히 잘못된 경우가 아니라면 불필요한 전면 재설계로 흘러가지 않습니다.

## 기본 CLI 호출 패턴

가능하면 아래처럼 비대화형 리뷰 호출을 사용합니다.

```powershell
pwsh -File .\scripts\run_claude_review.ps1 -PromptFile .\prompts\review_request_template.md
```

이 헬퍼 스크립트는 의도적으로 아래를 수행합니다.

- `PATH`에서 `claude`를 찾고
- 순수 리뷰 호출을 위해 도구를 끄고
- 편집 실행이 아닌 plan-mode 스타일 검토를 사용합니다
