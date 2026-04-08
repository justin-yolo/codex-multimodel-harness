# 리뷰 요청 템플릿

Gemini나 Claude에게 리뷰를 요청할 때 이 템플릿을 사용합니다.

## 작업

검토가 필요한 정확한 변경, 결정, 결과를 적습니다.

## 로컬 근거

- 관련 파일:
- 실행한 명령:
- 메트릭 또는 로그:
- 제약:

## 리뷰 요청 형식

아래 형식으로 답하게 요청합니다.

1. `verdict`: `approve`, `caution`, `block`
2. `severity`: `low`, `medium`, `high`
3. `safe_conclusions`
4. `risks_or_missing_checks`
5. `next_action`

파일이 포함되면 구체적인 파일 경로를 함께 적게 합니다.
