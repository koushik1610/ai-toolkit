#!/bin/bash
# doctor.sh — verify the ai-toolkit install is healthy. Read-only; changes nothing.
# Checks every expected symlink resolves into this repo, hooks are wired, and the
# ai-deslop import is present. Exits non-zero if anything is off so CI/you can catch drift.

set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
SETTINGS="${CLAUDE_DIR}/settings.json"
GLOBAL_MD="${CLAUDE_DIR}/CLAUDE.md"
FAIL=0

ok()   { echo "  ok    $1"; }
bad()  { echo "  FAIL  $1"; FAIL=1; }

check_links() {  # every $1/* should be a symlink at $2/<name> pointing back
  local srcroot="$1" dstdir="$2" name target
  for src in "$srcroot"/*; do
    [ -e "$src" ] || continue
    name="$(basename "$src")"
    target="${dstdir}/${name}"
    if [ -L "$target" ] && [ "$(readlink "$target")" = "${src%/}" ]; then
      ok "$target"
    else
      bad "$target (missing or not linked to repo)"
    fi
  done
}

echo "ai-toolkit doctor (repo: $REPO)"

echo "Skills:";   check_links "${REPO}/skills"   "${CLAUDE_DIR}/skills"
echo "Commands:"; check_links "${REPO}/commands" "${CLAUDE_DIR}/commands"
echo "Agents:";   check_links "${REPO}/agents"   "${CLAUDE_DIR}/agents"
echo "Hook links:"; check_links "${REPO}/hooks"  "${CLAUDE_DIR}/hooks"

echo "Hook wiring:"
if command -v jq >/dev/null 2>&1 && [ -f "$SETTINGS" ]; then
  for pair in "Stop:stop-memory-reminder.sh" "PreToolUse:pretooluse-guard.sh"; do
    ev="${pair%%:*}"; file="${pair##*:}"; cmd="${CLAUDE_DIR}/hooks/${file}"
    if jq -e --arg ev "$ev" --arg cmd "$cmd" \
         'any(.hooks[$ev][]?; (.hooks // []) | any(.command == $cmd))' "$SETTINGS" >/dev/null 2>&1; then
      ok "$ev -> $file"
    else
      bad "$ev hook not wired ($cmd)"
    fi
  done
else
  bad "settings.json missing or jq unavailable"
fi

echo "Global CLAUDE.md:"
if [ -f "$GLOBAL_MD" ] && grep -qF "<!-- ai-toolkit:ai-deslop -->" "$GLOBAL_MD"; then
  ok "ai-deslop rules imported"
else
  bad "ai-deslop import missing from $GLOBAL_MD"
fi

echo "Statusline:"
for s in statusline.sh statusline.ps1; do
  target="${CLAUDE_DIR}/${s}"
  if [ -L "$target" ] && [ "$(readlink "$target")" = "${REPO}/statusline/${s}" ]; then
    ok "$target"
  else
    bad "$target (missing or not linked to repo)"
  fi
done

echo "Hook scripts executable:"
for h in "${REPO}/hooks/"*.sh; do
  if [ -x "$h" ]; then ok "$(basename "$h")"; else bad "$(basename "$h") not executable"; fi
done

echo ""
if [ "$FAIL" = 0 ]; then echo "All checks passed."; else echo "Some checks FAILED — run ./install.sh to repair."; fi
exit "$FAIL"
