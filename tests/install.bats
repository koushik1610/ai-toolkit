#!/usr/bin/env bats
# Tests for install.sh / uninstall.sh / doctor.sh against a throwaway $HOME.
# Run: bats tests/install.bats   (requires bats-core and jq)

setup() {
  REPO="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  TEST_HOME="$(mktemp -d)"
  export TEST_HOME
}

teardown() {
  rm -rf "$TEST_HOME"
}

run_install()   { HOME="$TEST_HOME" run bash "$REPO/install.sh" "$@"; }
run_uninstall() { HOME="$TEST_HOME" run bash "$REPO/uninstall.sh"; }
run_doctor()    { HOME="$TEST_HOME" run bash "$REPO/doctor.sh"; }

@test "install creates skill, command, agent, and hook symlinks into repo" {
  run_install
  [ "$status" -eq 0 ]
  [ -L "$TEST_HOME/.claude/skills/llm-council" ]
  [ "$(readlink "$TEST_HOME/.claude/skills/llm-council")" = "$REPO/skills/llm-council" ]
  [ -L "$TEST_HOME/.claude/commands/bootstrap.md" ]
  [ -L "$TEST_HOME/.claude/agents/security-reviewer.md" ]
  [ -L "$TEST_HOME/.claude/hooks/pretooluse-guard.sh" ]
}

@test "install wires Stop and PreToolUse hooks once" {
  run_install
  cnt_stop="$(jq '[.hooks.Stop[].hooks[].command] | map(select(endswith("stop-memory-reminder.sh"))) | length' "$TEST_HOME/.claude/settings.json")"
  cnt_pre="$(jq '[.hooks.PreToolUse[].hooks[].command] | map(select(endswith("pretooluse-guard.sh"))) | length' "$TEST_HOME/.claude/settings.json")"
  [ "$cnt_stop" -eq 1 ]
  [ "$cnt_pre" -eq 1 ]
}

@test "install imports ai-deslop rules into global CLAUDE.md" {
  run_install
  grep -qF "ai-toolkit:ai-deslop" "$TEST_HOME/.claude/CLAUDE.md"
}

@test "doctor passes on a fresh install" {
  run_install
  run_doctor
  [ "$status" -eq 0 ]
}

@test "install is idempotent: re-run keeps one hook entry and doctor still passes" {
  run_install
  run_install
  [ "$status" -eq 0 ]
  cnt="$(jq '[.hooks.Stop[].hooks[].command] | map(select(endswith("stop-memory-reminder.sh"))) | length' "$TEST_HOME/.claude/settings.json")"
  [ "$cnt" -eq 1 ]
  run_doctor
  [ "$status" -eq 0 ]
}

@test "dry-run changes nothing" {
  run_install --dry-run
  [ "$status" -eq 0 ]
  [ ! -e "$TEST_HOME/.claude/skills/llm-council" ]
  [ ! -e "$TEST_HOME/.claude/settings.json" ]
}

@test "uninstall removes symlinks and hook entries; doctor then fails" {
  run_install
  run_uninstall
  [ "$status" -eq 0 ]
  [ ! -e "$TEST_HOME/.claude/skills/llm-council" ]
  [ ! -e "$TEST_HOME/.claude/hooks/pretooluse-guard.sh" ]
  cnt="$(jq '[.hooks.Stop[]?.hooks[]?.command // empty] | map(select(endswith("stop-memory-reminder.sh"))) | length' "$TEST_HOME/.claude/settings.json")"
  [ "$cnt" -eq 0 ]
  run_doctor
  [ "$status" -ne 0 ]
}
