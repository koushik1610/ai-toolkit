#!/bin/bash
# install.sh — link ai-toolkit into ~/.claude. Idempotent.
#
# - Symlinks every skill dir (skills/*) into ~/.claude/skills/
# - Symlinks every command (commands/*.md) into ~/.claude/commands/
# - Wires the global Stop memory-reminder hook into ~/.claude/settings.json
# - Imports ai-deslop rules into the global ~/.claude/CLAUDE.md
# - Backs up anything real it would replace (including the pre-refactor councils)
#
# Re-running is safe: existing correct symlinks are left alone.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
BACKUP_DIR="${CLAUDE_DIR}/.ai-toolkit-backups/$(date +%Y%m%d-%H%M%S)"
SETTINGS="${CLAUDE_DIR}/settings.json"
GLOBAL_MD="${CLAUDE_DIR}/CLAUDE.md"
HOOK="${REPO}/hooks/stop-memory-reminder.sh"

mkdir -p "${CLAUDE_DIR}/skills" "${CLAUDE_DIR}/commands"
chmod +x "${REPO}/hooks/"*.sh 2>/dev/null || true

backup() {  # move a real path out of the way before linking
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mkdir -p "$BACKUP_DIR"
    echo "  backing up $target -> $BACKUP_DIR/"
    mv "$target" "$BACKUP_DIR/"
  elif [ -L "$target" ]; then
    rm -f "$target"
  fi
}

link() {  # link $1 (source) -> $2 (target)
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "  ok   $dst"
    return
  fi
  backup "$dst"
  ln -s "$src" "$dst"
  echo "  link $dst -> $src"
}

echo "ai-toolkit install (repo: $REPO)"

echo "Skills:"
for dir in "${REPO}"/skills/*/; do
  name="$(basename "$dir")"
  link "${dir%/}" "${CLAUDE_DIR}/skills/${name}"
done

echo "Commands:"
for cmd in "${REPO}"/commands/*.md; do
  name="$(basename "$cmd")"
  link "$cmd" "${CLAUDE_DIR}/commands/${name}"
done

# Retire the pre-refactor, project-scoped council skills so the global wrappers are canonical.
echo "Retiring superseded project-scoped councils (if present):"
for legacy in "${HOME}/Code/.claude/skills/portfolio-design-council" \
              "${HOME}/Code/.claude/skills/portfolio-resume-council"; do
  if [ -e "$legacy" ] && [ ! -L "$legacy" ]; then
    backup "$legacy"
  fi
done

# Wire the global Stop hook into settings.json (requires jq for safe JSON merge).
echo "Stop hook -> $SETTINGS"
if command -v jq >/dev/null 2>&1; then
  [ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
  tmp="$(mktemp)"
  jq --arg cmd "$HOOK" '
    .hooks = (.hooks // {})
    | .hooks.Stop = (.hooks.Stop // [])
    | if any(.hooks.Stop[]?; (.hooks // []) | any(.command == $cmd))
      then .
      else .hooks.Stop += [ { "matcher": "", "hooks": [ { "type": "command", "command": $cmd } ] } ]
      end
  ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  echo "  wired (or already present)"
else
  echo "  jq not found — add this to ${SETTINGS} hooks.Stop manually:"
  echo "  { \"matcher\": \"\", \"hooks\": [ { \"type\": \"command\", \"command\": \"$HOOK\" } ] }"
fi

# Import ai-deslop rules into the global CLAUDE.md (always-on prose guidance).
echo "ai-deslop import -> $GLOBAL_MD"
MARK="<!-- ai-toolkit:ai-deslop -->"
if [ -f "$GLOBAL_MD" ] && grep -qF "$MARK" "$GLOBAL_MD"; then
  echo "  already imported"
else
  {
    echo ""
    echo "$MARK"
    echo "@${REPO}/skills/ai-deslop/rules.md"
    echo "<!-- /ai-toolkit:ai-deslop -->"
  } >> "$GLOBAL_MD"
  echo "  imported"
fi

echo "Done. Backups (if any): $BACKUP_DIR"
