#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

printf '%s\n' "===== Gemini 스모크 테스트 ====="
sh "$SCRIPT_DIR/run_gemini_review.sh" --prompt "Return exactly: GEMINI_SMOKE_OK"

printf '\n===== Claude 스모크 테스트 =====\n'
sh "$SCRIPT_DIR/run_claude_review.sh" --prompt "Return exactly: CLAUDE_SMOKE_OK"
