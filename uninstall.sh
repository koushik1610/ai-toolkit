#!/bin/bash
# uninstall.sh: remove the symlinks and config that install.sh added.
# Does NOT restore backups automatically; they live in ~/.claude/.ai-toolkit-backups/.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
SETTINGS="${CLAUDE_DIR}/settings.json"
GLOBAL_MD="${CLAUDE_DIR}/CLAUDE.md"

echo "ai-toolkit uninstall"

unlink_from() {  # remove symlinks in $2 that point into $1/*
  local srcroot="$1" dstdir="$2" name target
  for src in "$srcroot"/*; do
    name="$(basename "$src")"
    target="${dstdir}/${name}"
    if [ -L "$target" ] && [ "$(readlink "$target")" = "${src%/}" ]; then
      rm -f "$target"; echo "  unlink $target"
    fi
  done
}

unlink_from "${REPO}/skills"   "${CLAUDE_DIR}/skills"
unlink_from "${REPO}/commands" "${CLAUDE_DIR}/commands"
unlink_from "${REPO}/agents"   "${CLAUDE_DIR}/agents"
unlink_from "${REPO}/hooks"    "${CLAUDE_DIR}/hooks"

# Statusline scripts live directly in ~/.claude/ (not a subdir).
for s in statusline.sh statusline.py; do
  target="${CLAUDE_DIR}/${s}"
  if [ -L "$target" ] && [ "$(readlink "$target")" = "${REPO}/statusline/${s}" ]; then
    rm -f "$target"; echo "  unlink $target"
  fi
done

# Remove our hook entries (Stop + PreToolUse) by command path.
if command -v jq >/dev/null 2>&1 && [ -f "$SETTINGS" ]; then
  for cmd in "${CLAUDE_DIR}/hooks/stop-memory-reminder.sh" "${CLAUDE_DIR}/hooks/pretooluse-guard.sh"; do
    tmp="$(mktemp)"
    jq --arg cmd "$cmd" '
      if .hooks then
        .hooks |= with_entries(
          .value |= ( map( .hooks |= map(select(.command != $cmd)) ) | map(select((.hooks | length) > 0)) )
        )
      else . end
    ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  done
  echo "  removed Stop + PreToolUse hook entries"
fi

# Remove the ai-deslop import block from global CLAUDE.md.
if [ -f "$GLOBAL_MD" ]; then
  tmp="$(mktemp)"
  sed '/<!-- ai-toolkit:ai-deslop -->/,/<!-- \/ai-toolkit:ai-deslop -->/d' "$GLOBAL_MD" > "$tmp" && mv "$tmp" "$GLOBAL_MD"
  echo "  removed ai-deslop import from $GLOBAL_MD"
fi

echo "Done. Backups remain in ${CLAUDE_DIR}/.ai-toolkit-backups/: restore manually if needed."
