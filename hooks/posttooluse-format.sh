#!/bin/bash
# PostToolUse format hook: auto-formats the file Claude just wrote, by extension.
# Opt-in per project (wired by archetypes that need it). Best-effort: if the formatter
# isn't installed, it does nothing. Never blocks (PostToolUse runs after the tool).
#
# Disable for one call with AI_TOOLKIT_FORMAT=off.

[ "${AI_TOOLKIT_FORMAT:-on}" = "off" ] && exit 0

INPUT="$(cat)"
if command -v jq >/dev/null 2>&1; then
  FILE="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')"
else
  exit 0   # without jq we can't reliably find the file; skip
fi
[ -z "$FILE" ] || [ ! -f "$FILE" ] && exit 0

run() { command -v "$1" >/dev/null 2>&1 && "$@" >/dev/null 2>&1 || true; }

case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.md|*.html|*.yml|*.yaml)
    if command -v prettier >/dev/null 2>&1; then run prettier --write "$FILE"
    elif command -v npx >/dev/null 2>&1; then npx --no-install prettier --write "$FILE" >/dev/null 2>&1 || true; fi ;;
  *.py)
    run ruff format "$FILE"; run ruff check --fix "$FILE" ;;
  *.go)
    run gofmt -w "$FILE" ;;
  *.rs)
    run rustfmt "$FILE" ;;
  *.sh)
    run shfmt -w "$FILE" ;;
esac

exit 0
