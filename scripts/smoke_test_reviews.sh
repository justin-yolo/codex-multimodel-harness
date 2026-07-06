#!/bin/sh
set -u

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
FAILURES=""

run_smoke() {
  name="$1"
  script="$2"
  sentinel="$3"

  printf '%s\n' "===== $name smoke test ====="
  output="$(sh "$script" --prompt "Return exactly: $sentinel" 2>&1)"
  status="$?"
  if [ -n "$output" ]; then
    printf '%s\n' "$output"
  fi

  if [ "$status" -eq 0 ] && printf '%s\n' "$output" | grep -F "$sentinel" >/dev/null 2>&1; then
    printf '%s\n' "$name smoke: PASS"
  else
    printf '%s\n' "$name smoke: FAIL"
    FAILURES="${FAILURES}${name} exit ${status}; "
  fi
}

run_smoke "Gemini" "$SCRIPT_DIR/run_gemini_review.sh" "GEMINI_SMOKE_OK"

printf '\n'
run_smoke "Claude" "$SCRIPT_DIR/run_claude_review.sh" "CLAUDE_SMOKE_OK"

if [ -n "$FAILURES" ]; then
  printf '%s\n' "Smoke test failed: $FAILURES" >&2
  exit 1
fi
