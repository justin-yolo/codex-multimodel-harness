#!/bin/sh
set -eu

check_tool() {
  name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    path="$(command -v "$name")"
    version="$("$name" --version 2>/dev/null | head -n 1 || true)"
    printf '%s\tFOUND\t%s\t%s\n' "$name" "$path" "$version"
  else
    printf '%s\tMISSING\t-\t-\n' "$name"
    return 1
  fi
}

check_tool claude
check_tool gemini
