# Changelog

## Unreleased

- Initial toolkit.
  - Project-structure convention: routing `CLAUDE.md`, `WORKFLOW.md`, per-project memory layer,
    templates, and the MANDATORY auto-update instruction.
  - `ai-deslop` skill + always-on rules.
  - `llm-council` engine: persona library, lite/full modes, anonymous voting, and
    priority/disposition/score verdict formats.
  - Existing councils (`security`, `portfolio-design`, `portfolio-resume`) refactored into
    configs of the engine, with thin wrapper skills preserving their invocation names.
  - `/bootstrap` command + archetypes (generic, startup-rag, mcp-server, single-tool, web-frontend).
  - `install.sh` / `uninstall.sh` and the `stop-memory-reminder` hook.

- P0/P1 hardening.
  - Tests + CI: `bats` tests for install/uninstall/doctor and the guard, `shellcheck` in
    GitHub Actions.
  - `PreToolUse` guard hook: blocks destructive commands and obvious secrets (bypass with
    `AI_TOOLKIT_GUARD=off`). Wired globally by install.
  - `install.sh --dry-run` and `doctor.sh` health-check for the symlink model.
  - Dogfooded the convention: ai-toolkit now has its own routing `CLAUDE.md` + `WORKFLOW.md`.
  - `/council` and `/deslop` slash commands.
  - `SessionStart` hook (loads recent memory + git state) and opt-in `PostToolUse` format hook.
  - Curated agents: `security-reviewer`, `simplifier`. Install now symlinks `agents/` and
    `hooks/` into `~/.claude/`.

- `statusline/`: one-line truecolor status bar (repo, branch, 20-block context bar, 5h and
  weekly rate-limit bars, code velocity, model, cost). `statusline.sh` (bash) and
  `statusline.py` (Python, cross-platform, no `jq` dependency).
