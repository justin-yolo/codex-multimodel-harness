# .cmc-harness

이 폴더는 `AGENTS.md`, `HANDOFF.md`, `CLAUDE.md`, `GEMINI.md`에 적힌
협업 계약을 실제로 굴릴 수 있게 해 주는 포터블 유틸 모음입니다.

## 구성

- `scripts/doctor.py`: 로컬 필수 도구 설치 상태를 확인합니다.
- `scripts/run_dual_review.py`: 같은 프롬프트로 Claude CLI와 Gemini CLI를 모두 실행하고 결과를 저장합니다.
- `prompts/`: 재사용 가능한 리뷰 프롬프트 접두문과 근거 템플릿입니다.

## 사용 예시

대상 레포 루트에서:

```powershell
python .cmc-harness/scripts/doctor.py
python .cmc-harness/scripts/run_dual_review.py --prompt-file .cmc-harness/prompts/evidence_template.md
```
