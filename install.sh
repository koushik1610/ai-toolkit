#!/bin/bash
# install.sh — link ai-toolkit into ~/.claude. Idempotent.
#
# - Symlinks every skill dir (skills/*) into ~/.claude/skills/
# - Symlinks every command (commands/*.md) into ~/.claude/commands/
# - Symlinks every agent (agents/*.md) into ~/.claude/agents/
# - Wires global hooks into ~/.claude/settings.json:
#     Stop        -> stop-memory-reminder.sh
#     PreToolUse  -> pretooluse-guard.sh   (destructive-command + secret guard)
# - Imports ai-deslop rules into the global ~/.claude/CLAUDE.md
# - Backs up anything real it would replace (including the pre-refactor councils)
#
# Flags:
#   -n, --dry-run   Print what would happen; change nothing.
#
# Re-running is safe: existing correct symlinks and hook entries are left alone.

set -euo pipefail

DRY_RUN=0
case "${1:-}" in
  -n|--dry-run) DRY_RUN=1; echo "[dry-run] no changes will be made" ;;
esac

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
BACKUP_DIR="${CLAUDE_DIR}/.ai-toolkit-backups/$(date +%Y%m%d-%H%M%S)"
SETTINGS="${CLAUDE_DIR}/settings.json"
GLOBAL_MD="${CLAUDE_DIR}/CLAUDE.md"

run() { if [ "$DRY_RUN" = 1 ]; then echo "    would: $*"; else eval "$*"; fi; }

if [ "$DRY_RUN" = 0 ]; then
  mkdir -p "${CLAUDE_DIR}/skills" "${CLAUDE_DIR}/commands" "${CLAUDE_DIR}/agents" "${CLAUDE_DIR}/hooks"
  chmod +x "${REPO}/hooks/"*.sh 2>/dev/null || true
fi

backup() {  # move a real path out of the way before linking
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "  backup $target -> $BACKUP_DIR/"
    run "mkdir -p '$BACKUP_DIR'"
    run "mv '$target' '$BACKUP_DIR/'"
  elif [ -L "$target" ]; then
    run "rm -f '$target'"
  fi
}

link() {  # link $1 (source) -> $2 (target)
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "  ok   $dst"; return
  fi
  backup "$dst"
  run "ln -s '$src' '$dst'"
  echo "  link $dst -> $src"
}

# jq-based idempotent hook wiring: wire_hook <Event> <command-path>
wire_hook() {
  local event="$1" cmd="$2"
  if ! command -v jq >/dev/null 2>&1; then
    echo "  jq not found — add to ${SETTINGS} hooks.${event} manually:"
    echo "    { \"matcher\": \"\", \"hooks\": [ { \"type\": \"command\", \"command\": \"$cmd\" } ] }"
    return
  fi
  if [ "$DRY_RUN" = 1 ]; then echo "    would: wire ${event} -> $cmd (if absent)"; return; fi
  [ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
  local tmp; tmp="$(mktemp)"
  jq --arg ev "$event" --arg cmd "$cmd" '
    .hooks = (.hooks // {})
    | .hooks[$ev] = (.hooks[$ev] // [])
    | if any(.hooks[$ev][]?; (.hooks // []) | any(.command == $cmd))
      then .
      else .hooks[$ev] += [ { "matcher": "", "hooks": [ { "type": "command", "command": $cmd } ] } ]
      end
  ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  echo "  hook ${event} -> $cmd (wired or already present)"
}

echo "ai-toolkit install (repo: $REPO)"

echo "Skills:"
for dir in "${REPO}"/skills/*/; do link "${dir%/}" "${CLAUDE_DIR}/skills/$(basename "$dir")"; done

echo "Commands:"
for cmd in "${REPO}"/commands/*.md; do link "$cmd" "${CLAUDE_DIR}/commands/$(basename "$cmd")"; done

echo "Agents:"
for ag in "${REPO}"/agents/*.md; do
  [ -e "$ag" ] || continue
  link "$ag" "${CLAUDE_DIR}/agents/$(basename "$ag")"
done

echo "Hooks:"
for h in "${REPO}"/hooks/*.sh; do link "$h" "${CLAUDE_DIR}/hooks/$(basename "$h")"; done

echo "Statusline (linked, not auto-wired):"
for s in "${REPO}"/statusline/statusline.sh "${REPO}"/statusline/statusline.ps1; do
  [ -e "$s" ] && link "$s" "${CLAUDE_DIR}/$(basename "$s")"
done
echo "  to enable: set settings.json statusLine.command to 'bash $HOME/.claude/statusline.sh'"

echo "Retiring superseded project-scoped councils (if present):"
for legacy in "${HOME}/Code/.claude/skills/portfolio-design-council" \
              "${HOME}/Code/.claude/skills/portfolio-resume-council"; do
  [ -e "$legacy" ] && [ ! -L "$legacy" ] && backup "$legacy"
done

echo "Global hooks -> $SETTINGS"
wire_hook Stop       "${CLAUDE_DIR}/hooks/stop-memory-reminder.sh"
wire_hook PreToolUse "${CLAUDE_DIR}/hooks/pretooluse-guard.sh"

echo "ai-deslop import -> $GLOBAL_MD"
MARK="<!-- ai-toolkit:ai-deslop -->"
if [ -f "$GLOBAL_MD" ] && grep -qF "$MARK" "$GLOBAL_MD"; then
  echo "  already imported"
elif [ "$DRY_RUN" = 1 ]; then
  echo "    would: append ai-deslop import to $GLOBAL_MD"
else
  printf '\n%s\n@%s\n<!-- /ai-toolkit:ai-deslop -->\n' "$MARK" "${REPO}/skills/ai-deslop/rules.md" >> "$GLOBAL_MD"
  echo "  imported"
fi

echo "Done."
if [ "$DRY_RUN" = 0 ]; then
  echo "Run ./doctor.sh to verify, or ./uninstall.sh to remove."
fi
exit 0
