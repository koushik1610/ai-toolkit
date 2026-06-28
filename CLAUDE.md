# ai-toolkit

> Routing file. Detail lives in `conventions/`, per-skill `SKILL.md`s, and `README.md`.
> This repo follows its own project-structure standard (see `conventions/PROJECT-STRUCTURE.md`).

## 1. What this is

Koushik's personal toolkit for setting up AI-development workspaces. The repo is the source
of truth; `install.sh` symlinks `skills/`, `commands/`, `agents/`, and `hooks/` into
`~/.claude`, so edits here are live. Claude Code only (v1). How it's used: see
[WORKFLOW.md](WORKFLOW.md).

## 2. Layout

- `conventions/`: the project-structure standard + templates.
- `skills/`: `ai-deslop`, the `llm-council` engine + persona library + council configs, and
  the thin council wrappers.
- `commands/`: `/bootstrap`, `/council`, `/deslop`.
- `agents/`: curated subagents (`security-reviewer`, `simplifier`).
- `hooks/`: Stop, PreToolUse guard, SessionStart, PostToolUse format.
- `install.sh` / `uninstall.sh` / `doctor.sh`: symlink lifecycle. `tests/`, bats + shellcheck.

## 3. Hard rules

1. **CLAUDE.md routes, never dumps.** Keep templates and this file under 150 lines; detail
   goes in `SKILL.md`s / `conventions/`. Because a bloated router gets skimmed.
2. **Anything executable gets a test.** `install.sh`/`uninstall.sh`/`doctor.sh`/hooks mutate or
   guard the user's global config; a silent bug is costly. Add/extend `tests/` with the change.
3. **Never break installed councils.** `security`, `portfolio-design`, `portfolio-resume` are
   derived from `llm-council`; if you touch the engine, re-verify all three still produce their
   verdict shape (see `skills/llm-council/councils/`).
4. **Idempotent, reversible, backed-up.** Install re-runs are no-ops; uninstall reverses;
   anything real that's replaced goes to `~/.claude/.ai-toolkit-backups/`.
5. **No bloat.** Personal toolkit. Add breadth only when a need is real and reused, not because
   other toolkits have it (no plugin marketplace, no agent zoo, no heavy memory infra for v1).
6. **Prose follows ai-deslop.** No em-dashes, no corporate filler, in this repo's docs too.

## 4. Where things live

- The standard → [conventions/PROJECT-STRUCTURE.md](conventions/PROJECT-STRUCTURE.md)
- Council engine → [skills/llm-council/SKILL.md](skills/llm-council/SKILL.md)
- Prose rules → [skills/ai-deslop/rules.md](skills/ai-deslop/rules.md)
- How to run tests → [tests/README.md](tests/README.md)

## 5. What "done" looks like

`shellcheck install.sh uninstall.sh doctor.sh hooks/*.sh` clean, `bats tests/` green, and
`./doctor.sh` passes after `./install.sh`. For council changes, the three preset councils still
run and produce their expected output.
