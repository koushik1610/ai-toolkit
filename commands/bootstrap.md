---
description: Scaffold a new project with the standard AI-dev structure (routing CLAUDE.md, WORKFLOW.md, memory layer, .claude/ skeleton).
argument-hint: [project-name] [archetype]
---

# /bootstrap

Scaffold a new project using the ai-toolkit project-structure standard. Produces a routing
`CLAUDE.md`, a `WORKFLOW.md`, an `AGENTS.md` alias, the `.claude/` memory + extension
skeleton, and a committed `settings.json` with the memory Stop hook.

Templates live in the ai-toolkit repo under `conventions/templates/`; archetypes under
`archetypes/`. The convention itself is documented in `conventions/PROJECT-STRUCTURE.md`. Read it if unsure where something goes.

## Arguments

`$ARGUMENTS` = `[project-name] [archetype]`. If either is missing, ask.

Archetypes: `generic` (default), `startup-rag`, `mcp-server`, `single-tool`, `web-frontend`.

## Steps

1. **Confirm inputs.** Project name and archetype. Ask one or two quick questions to fill the
   template placeholders: one-paragraph purpose, stack, owners, and the top 3–5 hard rules.
   Don't over-ask: sensible defaults are fine, the user edits after.

2. **Locate sources.** Find the ai-toolkit repo (default `~/Code/ai-toolkit`). Use
   `conventions/templates/` for the base files and `archetypes/<archetype>/` for any
   archetype-specific overrides (extra rule files, seeded hard rules, settings).

3. **Generate files** in the target project root:
   - `CLAUDE.md` from `CLAUDE.md.tmpl`: fill placeholders. **Keep it under 150 lines**; push
     detail into rules/docs. It must route, not dump.
   - `WORKFLOW.md` from `WORKFLOW.md.tmpl`: user personas, journeys, stories, non-goals.
   - `AGENTS.md` from `AGENTS.md.tmpl`.
   - `.claude/rules/`: copy the four `memory-*.md` stubs + `auto-update-memory.md`, plus any
     archetype domain rules (e.g. `security.md` for `startup-rag`).
   - `.claude/settings.json` from `settings.json.tmpl`: the Stop memory-reminder hook +
     starter permissions, merged with any archetype additions.
   - `.claude/` skeleton dirs: `commands/`, `agents/`, `skills/`, `hooks/` (with a short
     `README.md` in each explaining what goes there).
   - `docs/` with an empty `architecture.md` stub.

4. **Apply the archetype.** Seed the archetype's hard rules into `CLAUDE.md §3` and add its
   rule files. See `archetypes/<archetype>/README.md`.

5. **Report.** Print the tree created and a short checklist of placeholders the user still
   needs to fill (purpose, hard rules, personas, verification gate).

## Rules

- Never overwrite an existing `CLAUDE.md`/`WORKFLOW.md` without confirming.
- The generated `CLAUDE.md` must stay under 150 lines.
- Memory files are project-scoped; they do not touch global native memory.
- Do not invent project facts. Leave `{{placeholders}}` where you don't have the answer and
  list them in the report.
