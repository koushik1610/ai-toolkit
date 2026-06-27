#!/bin/bash
# Stop hook — safety net for the memory layer.
# Reads the session transcript on stdin, pattern-matches for signals that something worth
# remembering happened, and nudges Claude to update the memory files. The CLAUDE.md MANDATORY
# instruction handles ~90% of updates as-you-go; this catches sessions where it forgot.
#
# Wired by install.sh into ~/.claude/settings.json (global) and by /bootstrap into a
# project's .claude/settings.json.

CONTEXT=$(cat)

STRONG_PATTERNS="fixed|workaround|gotcha|that's wrong|check again|we already|should have|discovered|realized|turns out|decided|let's go with|prefer"
WEAK_PATTERNS="error|bug|issue|problem|fail"

if echo "$CONTEXT" | grep -qiE "$STRONG_PATTERNS"; then
    cat << 'EOF'
{
  "decision": "approve",
  "systemMessage": "This session involved fixes, decisions, or discoveries. Before finishing, update the memory files you haven't already: .claude/rules/memory-decisions.md (with date), memory-preferences.md, memory-profile.md, or memory-sessions.md. Update AS YOU GO next time — do not ask, just write."
}
EOF
elif echo "$CONTEXT" | grep -qiE "$WEAK_PATTERNS"; then
    echo '{"decision":"approve","systemMessage":"If you learned something non-obvious this session, capture it in .claude/rules/memory-sessions.md or memory-decisions.md."}'
else
    echo '{"decision": "approve"}'
fi
