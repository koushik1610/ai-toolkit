#!/usr/bin/env bats
# Smoke test for the bash status line: valid JSON in -> non-empty bar with the repo name.
# Run: bats tests/statusline.bats   (requires jq)

setup() {
  REPO="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  SH="$REPO/statusline/statusline.sh"
  PY="$REPO/statusline/statusline.py"
}

@test "bash: renders a line containing the model and cost for valid JSON" {
  json='{"model":{"display_name":"Opus 4.8"},"workspace":{"current_dir":"'"$REPO"'"},"context_window":{"used_percentage":42},"cost":{"total_cost_usd":1.23,"total_lines_added":10,"total_lines_removed":2}}'
  run bash -c "printf '%s' '$json' | bash '$SH'"
  [ "$status" -eq 0 ]
  [ -n "$output" ]
  [[ "$output" == *"Opus 4.8"* ]]
  [[ "$output" == *"1.23"* ]]
}

@test "bash: omits 5h/7d segments when rate_limits absent" {
  json='{"model":{"display_name":"Opus 4.8"},"context_window":{"used_percentage":10},"cost":{"total_cost_usd":0}}'
  run bash -c "printf '%s' '$json' | bash '$SH'"
  [ "$status" -eq 0 ]
  [[ "$output" != *"5h"* ]]
  [[ "$output" != *"7d"* ]]
}

@test "python: renders the same model and cost for valid JSON" {
  command -v python3 >/dev/null || skip "python3 not installed"
  json='{"model":{"display_name":"Opus 4.8"},"workspace":{"current_dir":"'"$REPO"'"},"context_window":{"used_percentage":42},"cost":{"total_cost_usd":1.23,"total_lines_added":10,"total_lines_removed":2}}'
  run bash -c "printf '%s' '$json' | python3 '$PY'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Opus 4.8"* ]]
  [[ "$output" == *"1.23"* ]]
}

@test "python: omits 5h/7d segments when rate_limits absent" {
  command -v python3 >/dev/null || skip "python3 not installed"
  json='{"model":{"display_name":"Opus 4.8"},"context_window":{"used_percentage":10},"cost":{"total_cost_usd":0}}'
  run bash -c "printf '%s' '$json' | python3 '$PY'"
  [ "$status" -eq 0 ]
  [[ "$output" != *"5h"* ]]
  [[ "$output" != *"7d"* ]]
}
