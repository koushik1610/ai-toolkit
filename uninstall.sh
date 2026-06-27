#!/bin/bash
# uninstall.sh — remove the symlinks and config that install.sh added.
# Does NOT restore backups automatically; they live in ~/.claude/.ai-toolkit-backups/.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
SETTINGS="${CLAUDE_DIR}/settings.json"
GLOBAL_MD="${CLAUDE_DIR}/CLAUDE.md"
HOOK="${REPO}/hooks/stop-memory-reminder.sh"

echo "ai-toolkit uninstall"

# Remove skill symlinks that point into this repo.
for dir in "${REPO}"/skills/*/; do
  name="$(basename "$dir")"
  target="${CLAUDE_DIR}/skills/${name}"
  if [ -L "$target" ] && [ "$(readlink "$target")" = "${dir%/}" ]; then
    rm -f "$target"; echo "  unlink $target"
  fi
done

# Remove command symlinks that point into this repo.
for cmd in "${REPO}"/commands/*.md; do
  name="$(basename "$cmd")"
  target="${CLAUDE_DIR}/commands/${name}"
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$cmd" ]; then
    rm -f "$target"; echo "  unlink $target"
  fi
done

# Remove the Stop hook entry.
if command -v jq >/dev/null 2>&1 && [ -f "$SETTINGS" ]; then
  tmp="$(mktemp)"
  jq --arg cmd "$HOOK" '
    if .hooks.Stop then
      .hooks.Stop |= map( .hooks |= map(select(.command != $cmd)) ) | .hooks.Stop |= map(select((.hooks | length) > 0))
    else . end
  ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  echo "  removed Stop hook entry"
fi

# Remove the ai-deslop import block from global CLAUDE.md.
if [ -f "$GLOBAL_MD" ]; then
  tmp="$(mktemp)"
  sed '/<!-- ai-toolkit:ai-deslop -->/,/<!-- \/ai-toolkit:ai-deslop -->/d' "$GLOBAL_MD" > "$tmp" && mv "$tmp" "$GLOBAL_MD"
  echo "  removed ai-deslop import from $GLOBAL_MD"
fi

echo "Done. Backups remain in ${CLAUDE_DIR}/.ai-toolkit-backups/ — restore manually if needed."
