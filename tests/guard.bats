#!/usr/bin/env bats
# Tests for the PreToolUse guard. Feeds it tool-call JSON and asserts block (exit 2) vs allow.
# Run: bats tests/guard.bats   (requires bats-core and jq)

setup() {
  REPO="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  GUARD="$REPO/hooks/pretooluse-guard.sh"
}

guard() { run bash -c "printf '%s' '$1' | bash '$GUARD'"; }

@test "blocks rm -rf on a root path" {
  guard '{"tool_name":"Bash","tool_input":{"command":"rm -rf /"}}'
  [ "$status" -eq 2 ]
}

@test "blocks force-push to main" {
  guard '{"tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}'
  [ "$status" -eq 2 ]
}

@test "allows an ordinary command" {
  guard '{"tool_name":"Bash","tool_input":{"command":"npm test"}}'
  [ "$status" -eq 0 ]
}

@test "blocks an AWS access key id in file content" {
  guard '{"tool_name":"Write","tool_input":{"file_path":"/tmp/x.env","content":"AWS_KEY=AKIAIOSFODNN7EXAMPLE"}}'
  [ "$status" -eq 2 ]
}

@test "blocks a private key header in file content" {
  guard '{"tool_name":"Write","tool_input":{"file_path":"/tmp/id","content":"-----BEGIN OPENSSH PRIVATE KEY-----"}}'
  [ "$status" -eq 2 ]
}

@test "allows ordinary file content" {
  guard '{"tool_name":"Write","tool_input":{"file_path":"/tmp/readme.md","content":"# Hello\nthis is fine"}}'
  [ "$status" -eq 0 ]
}

@test "AI_TOOLKIT_GUARD=off bypasses the block" {
  run bash -c "AI_TOOLKIT_GUARD=off; export AI_TOOLKIT_GUARD; printf '%s' '{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"rm -rf /\"}}' | bash '$GUARD'"
  [ "$status" -eq 0 ]
}
