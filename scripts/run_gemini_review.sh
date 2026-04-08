#!/bin/sh
set -eu

MODEL="${HARNESS_GEMINI_MODEL:-gemini-3.1-pro-preview}"
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

if ! command -v gemini >/dev/null 2>&1; then
  echo "PATH에서 Gemini CLI를 찾지 못했습니다." >&2
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

# Current Gemini CLI parsing is fragile with multiline --prompt values.
# Pipe the real payload over stdin and keep headless mode enabled with a placeholder.
printf '%s' "$PAYLOAD" | gemini --prompt " " --model "$MODEL" --approval-mode plan --output-format text
