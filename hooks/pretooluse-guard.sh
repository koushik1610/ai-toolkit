#!/bin/bash
# PreToolUse guard — a speed bump, not a guarantee.
# Blocks clearly destructive Bash commands and flags likely secrets in file writes.
#
# Protocol: reads the tool-call JSON on stdin. To BLOCK, exit 2 with a reason on stderr
# (Claude sees it and stops). To allow, exit 0 silently.
#
# Bypass for a single call: set AI_TOOLKIT_GUARD=off in the environment.
# This does NOT replace git pre-commit secret scanning — keep that as the real net.

[ "${AI_TOOLKIT_GUARD:-on}" = "off" ] && exit 0

INPUT="$(cat)"

# Extract tool name + relevant fields (jq if present, else fall back to the raw blob).
if command -v jq >/dev/null 2>&1; then
  TOOL="$(printf '%s' "$INPUT" | jq -r '.tool_name // empty')"
  CMD="$(printf '%s' "$INPUT"  | jq -r '.tool_input.command // empty')"
  CONTENT="$(printf '%s' "$INPUT" | jq -r '[.tool_input.content, .tool_input.new_string] | map(select(.)) | join("\n") // empty')"
  FILE="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')"
else
  TOOL=""; CMD="$INPUT"; CONTENT="$INPUT"; FILE=""
fi

block() { echo "BLOCKED by ai-toolkit pretooluse-guard: $1" >&2; echo "Override for one call with AI_TOOLKIT_GUARD=off if you are sure." >&2; exit 2; }

# --- Destructive Bash patterns -------------------------------------------------
# grep patterns are intentionally literal single-quoted strings (no shell expansion).
# shellcheck disable=SC2016
if [ "$TOOL" = "Bash" ] || [ -z "$TOOL" ]; then
  # rm -rf on / or $HOME or a bare ~ ; recursive force deletes of broad roots
  echo "$CMD" | grep -qiE 'rm[[:space:]]+(-[a-z]*r[a-z]*f|-[a-z]*f[a-z]*r)[[:space:]]+(/|~|\$HOME|/\*)([[:space:]]|$)' \
    && block "recursive force-delete of a root path"
  # git force-push to main/master
  echo "$CMD" | grep -qiE 'git[[:space:]]+push.*(--force|-f)([[:space:]].*)?(origin[[:space:]]+)?(main|master)' \
    && block "force-push to main/master"
  # history-destroying or remote-wipe operations
  echo "$CMD" | grep -qiE 'git[[:space:]]+push.*--mirror|:refs/heads/' \
    && block "remote branch deletion / mirror push"
  # disk/format level
  echo "$CMD" | grep -qiE '\b(mkfs|dd[[:space:]]+if=|:\(\)\{|chmod[[:space:]]+-R[[:space:]]+777[[:space:]]+/)' \
    && block "disk-format / fork-bomb / world-writable root"
fi

# --- Secret patterns in file writes -------------------------------------------
if [ -n "$CONTENT" ]; then
  # Skip the toolkit's own guard/rules files (they legitimately contain the patterns).
  case "$FILE" in
    *ai-toolkit/hooks/*|*ai-toolkit/skills/ai-deslop/*) exit 0 ;;
  esac
  # AWS access key id, generic high-entropy assignments, private key headers, GH/Slack tokens
  echo "$CONTENT" | grep -qE 'AKIA[0-9A-Z]{16}' \
    && block "looks like an AWS access key id"
  echo "$CONTENT" | grep -qE -- '-----BEGIN[[:space:]](RSA|OPENSSH|EC|PGP|DSA)?[[:space:]]?PRIVATE KEY-----' \
    && block "looks like a private key"
  echo "$CONTENT" | grep -qE '(xox[baprs]-[0-9A-Za-z-]{10,}|ghp_[0-9A-Za-z]{30,}|github_pat_[0-9A-Za-z_]{30,})' \
    && block "looks like a Slack/GitHub token"
  echo "$CONTENT" | grep -qiE '(aws_secret_access_key|api[_-]?key|secret[_-]?key|password|passwd|token)[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9/+_=-]{16,}' \
    && block "looks like a hardcoded secret/credential assignment"
fi

exit 0
