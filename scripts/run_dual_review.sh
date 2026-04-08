#!/bin/sh
set -eu

CLAUDE_MODEL="${HARNESS_CLAUDE_MODEL:-claude-opus-4-6}"
GEMINI_MODEL="${HARNESS_GEMINI_MODEL:-gemini-3.1-pro-preview}"
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
    --claude-model)
      CLAUDE_MODEL="$2"
      shift 2
      ;;
    --gemini-model)
      GEMINI_MODEL="$2"
      shift 2
      ;;
    *)
      echo "알 수 없는 인자: $1" >&2
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

if [ -n "$PROMPT_FILE" ]; then
  printf '%s\n' "===== Gemini 비판적 리뷰 ====="
  sh "$SCRIPT_DIR/run_gemini_review.sh" --prompt-file "$PROMPT_FILE" --model "$GEMINI_MODEL"

  printf '\n===== Claude 리드 리뷰 =====\n'
  sh "$SCRIPT_DIR/run_claude_review.sh" --prompt-file "$PROMPT_FILE" --model "$CLAUDE_MODEL"
elif [ -n "$PROMPT" ]; then
  printf '%s\n' "===== Gemini 비판적 리뷰 ====="
  sh "$SCRIPT_DIR/run_gemini_review.sh" --prompt "$PROMPT" --model "$GEMINI_MODEL"

  printf '\n===== Claude 리드 리뷰 =====\n'
  sh "$SCRIPT_DIR/run_claude_review.sh" --prompt "$PROMPT" --model "$CLAUDE_MODEL"
else
  PAYLOAD="$(cat)"
  if [ -z "$PAYLOAD" ]; then
    echo "프롬프트 내용이 없습니다. --prompt, --prompt-file 또는 stdin을 사용하세요." >&2
    exit 1
  fi

  printf '%s\n' "===== Gemini 비판적 리뷰 ====="
  printf '%s' "$PAYLOAD" | sh "$SCRIPT_DIR/run_gemini_review.sh" --model "$GEMINI_MODEL"

  printf '\n===== Claude 리드 리뷰 =====\n'
  printf '%s' "$PAYLOAD" | sh "$SCRIPT_DIR/run_claude_review.sh" --model "$CLAUDE_MODEL"
fi
