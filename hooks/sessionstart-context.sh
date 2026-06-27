#!/bin/bash
# SessionStart hook — closes the memory loop the Stop hook starts.
# Stdout from a SessionStart hook is injected as context, so this surfaces recent project
# memory and repo state at the top of each session.
#
# Safe in any directory: prints nothing disruptive if there's no memory/git.

set -euo pipefail

echo "## Session context (ai-toolkit sessionstart hook)"

# Recent session memory, if the project uses the memory layer.
SESS=".claude/rules/memory-sessions.md"
if [ -f "$SESS" ]; then
  echo ""
  echo "### Recent sessions (from $SESS)"
  # Print the first ~25 lines after the heading, skipping the template scaffold.
  grep -vE '^\s*$' "$SESS" | head -n 25
fi

# Open decisions/preferences pointers (just announce they exist).
for f in .claude/rules/memory-decisions.md .claude/rules/memory-preferences.md; do
  [ -f "$f" ] && echo "- memory file present: $f"
done

# Repo state.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo ""
  echo "### Git"
  echo "- branch: $(git branch --show-current 2>/dev/null || echo '(detached)')"
  CHANGED="$(git status -s 2>/dev/null | head -n 15)"
  if [ -n "$CHANGED" ]; then
    echo "- uncommitted changes:"
    # shellcheck disable=SC2001
    echo "$CHANGED" | sed 's/^/    /'
  else
    echo "- working tree clean"
  fi
fi

exit 0
