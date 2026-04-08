#!/bin/sh
set -eu

MODEL="${HARNESS_CLAUDE_MODEL:-claude-opus-4-6}"
PROMPT=""
PROMPT_FILE=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --prompt)
      PROMPT="$2"
      shift 2
      ;;
    --prompt-file)
      PROMPT_FILE="$2"
      shift 2
      ;;
    --model)
      MODEL="$2"
      shift 2
      ;;
    *)
      echo "알 수 없는 인자: $1" >&2
      exit 1
      ;;
  esac
done

if ! command -v claude >/dev/null 2>&1; then
  echo "PATH에서 Claude CLI를 찾지 못했습니다." >&2
  exit 1
fi

if [ -n "$PROMPT_FILE" ]; then
  PAYLOAD="$(cat "$PROMPT_FILE")"
elif [ -n "$PROMPT" ]; then
  PAYLOAD="$PROMPT"
else
  PAYLOAD="$(cat)"
fi

if [ -z "$PAYLOAD" ]; then
  echo "프롬프트 내용이 없습니다. --prompt, --prompt-file 또는 stdin을 사용하세요." >&2
  exit 1
fi

printf '%s' "$PAYLOAD" | claude -p --model "$MODEL" --tools "" --permission-mode plan --output-format text
