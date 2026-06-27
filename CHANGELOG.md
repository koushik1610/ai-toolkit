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
