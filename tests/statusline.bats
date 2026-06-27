#!/usr/bin/env bats
# Smoke test for the bash status line: valid JSON in -> non-empty bar with the repo name.
# Run: bats tests/statusline.bats   (requires jq)

setup() {
  REPO="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  SL="$REPO/statusline/statusline.sh"
}

@test "renders a line containing the model and cost for valid JSON" {
  json='{"model":{"display_name":"Opus 4.8"},"workspace":{"current_dir":"'"$REPO"'"},"context_window":{"used_percentage":42},"cost":{"total_cost_usd":1.23,"total_lines_added":10,"total_lines_removed":2}}'
  run bash -c "printf '%s' '$json' | bash '$SL'"
  [ "$status" -eq 0 ]
  [ -n "$output" ]
  [[ "$output" == *"Opus 4.8"* ]]
  [[ "$output" == *"1.23"* ]]
}

@test "omits 5h/7d segments when rate_limits absent" {
  json='{"model":{"display_name":"Opus 4.8"},"context_window":{"used_percentage":10},"cost":{"total_cost_usd":0}}'
  run bash -c "printf '%s' '$json' | bash '$SL'"
  [ "$status" -eq 0 ]
  [[ "$output" != *"5h"* ]]
  [[ "$output" != *"7d"* ]]
}
