# ai-toolkit: Workflow & User Stories

How the toolkit is used. The "user" is Koushik setting up and working across AI-dev projects.

## Personas

### Koushik: starting a new project
- **Context:** spinning up a new repo and wants it AI-ready from commit one.
- **Goal:** a standard structure (routing CLAUDE.md, WORKFLOW.md, memory layer, safe hooks)
  without hand-assembling it each time.
- **Pain today:** every project's CLAUDE.md drifts; no shared convention; setup is manual.

### Koushik: working day to day
- **Context:** mid-task in any project on the laptop.
- **Goal:** the same skills, commands, hooks, and agents available everywhere, always current.
- **Pain today:** tools live in scattered project dirs; updating one doesn't update the rest.

### Koushik: reviewing an ask or a project
- **Context:** facing a decision, a design, or a finished feature and wants more than one lens.
- **Goal:** convene a council and get a prioritized P0/P1/P2 (or a security verdict, or a score).
- **Pain today:** a single pass misses angles; reviews aren't repeatable.

## User journeys

### Journey: bootstrap a new project
1. `git init` a new repo, open Claude Code.
2. Run `/bootstrap <name> <archetype>`.
3. Get a routing CLAUDE.md, WORKFLOW.md, `.claude/rules/` memory layer, and a settings.json
   with the memory + guard hooks wired.
4. Fill the placeholders the report lists; start building.

### Journey: install / update the toolkit
1. Clone or `git pull` ai-toolkit.
2. `./install.sh` (idempotent): symlinks everything into `~/.claude`, wires global hooks.
3. `./doctor.sh` confirms health. Edits to the repo are live immediately (symlinks).

### Journey: run a review
1. `/council --full <target>` (or `/council --council security <diff>`), or invoke a preset
   council skill directly.
2. Read the prioritized verdict; the full report is saved to `council-reviews/`.

## Primary flows (user stories)

- [x] As Koushik, I want one source of truth symlinked into `~/.claude`, so editing a tool once
  updates it everywhere. **Acceptance:** `./doctor.sh` shows all links resolving into the repo.
- [x] As Koushik, I want safe defaults on global tooling, so I can't accidentally `rm -rf` or
  commit a secret. **Acceptance:** `guard.bats` passes; the guard blocks those and allows normal calls.
- [x] As Koushik, I want a council I can convene in one command, so reviews are repeatable.
  **Acceptance:** `/council` runs the engine and writes a dated verdict file.
- [x] As Koushik, I want new projects scaffolded to the standard, so structure never drifts.
  **Acceptance:** `/bootstrap` emits a <150-line CLAUDE.md + WORKFLOW.md + memory layer.

## Non-goals

- Not a product for other people: no marketplace, no onboarding, no multi-user concerns (v1).
- Not cross-tool yet: Claude Code only; AGENTS.md alias is the only nod to Cursor/Codex.
- Not a kitchen sink: breadth is added only when a need is real and recurring.

## Success metrics

- New project fully scaffolded in one `/bootstrap` run.
- `./doctor.sh` green after every `./install.sh`.
- Zero council regressions when the engine changes (the three presets keep working).
