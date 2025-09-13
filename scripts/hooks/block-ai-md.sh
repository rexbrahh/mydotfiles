#!/usr/bin/env bash
set -euo pipefail
fail=0
for f in "$@"; do
  case "$f" in
    *.ai.md|*-ai.md|*_ai.md)
      echo "ERROR: AI-generated Markdown filename pattern blocked: $f" >&2
      fail=1
      ;;
  esac
  if [[ "$f" == */ai-generated/* || "$f" == */docs/ai/* ]]; then
    echo "ERROR: AI-generated docs directory blocked: $f" >&2
    fail=1
  fi
  # Block OS junk if ever staged by mistake
  if [[ "$(basename "$f")" == ".DS_Store" ]]; then
    echo "ERROR: .DS_Store should not be committed: $f" >&2
    fail=1
  fi
done
exit $fail
