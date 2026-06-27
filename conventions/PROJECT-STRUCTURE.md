# Project structure standard

How every project I start should be laid out so that Claude (and any other AI tool)
has exactly the context it needs, in the right place, without bloat.

## The core idea: CLAUDE.md is a router, not a knowledge dump

`CLAUDE.md` is loaded into context **every session**. If it grows past ~150 lines,
Claude skims it and misses what matters. So it stays small and points elsewhere.

```
project/
  CLAUDE.md            # <150 lines: identity, stack, hard rules, links out
  WORKFLOW.md          # user stories — who uses this and how
  AGENTS.md            # thin alias → "read CLAUDE.md"
  docs/                # architecture, deeper specs
  .claude/
    rules/             # auto-loaded, focused topic files
      memory-profile.md
      memory-preferences.md
      memory-decisions.md
      memory-sessions.md
      auto-update-memory.md   # the MANDATORY update protocol
      <domain>.md             # security.md, code-style.md, etc.
    commands/          # slash commands (project verbs)
    agents/            # specialized subagents
    skills/            # project-local skills
    hooks/             # shell hooks wired in settings.json
    settings.json      # committed: permissions + hooks
```

## What goes where

| File | Holds | Does NOT hold |
|------|-------|---------------|
| `CLAUDE.md` | Identity/purpose, stack, 5–15 hard rules, links to everything else | Long architecture, user stories, knowledge dumps |
| `WORKFLOW.md` | User personas, journeys, primary flows, acceptance criteria, non-goals | How Claude should code, tech decisions |
| `.claude/rules/*.md` | Focused, auto-loaded specs (security, code-style, memory) | One giant file |
| `docs/` | Architecture diagrams, deep design, ADRs | Things needed every session |

## The memory layer

Four rolling files under `.claude/rules/`, auto-loaded every session:

- **memory-profile.md** — durable facts about the project and the people.
- **memory-preferences.md** — how things are done here (conventions, tooling choices).
- **memory-decisions.md** — dated decisions, so choices stay consistent over time.
- **memory-sessions.md** — rolling summary of recent substantive work.

These are project-scoped. They are **separate** from Claude Code's global native
auto-memory (`~/.claude/.../memory/MEMORY.md`), which stays the home for facts about
me personally. Project memory = this project; global memory = me.

`auto-update-memory.md` makes Claude keep these current **as it works**, not at the
end. A global Stop hook (`stop-memory-reminder.sh`) is the safety net that nudges
when a session involved fixes or discoveries.

## Rules of thumb

1. If `CLAUDE.md` exceeds 150 lines, move detail into `.claude/rules/` or `docs/`.
2. Every hard rule states the *why*, and prefers the negative ("never X, because Y").
3. `WORKFLOW.md` is written from the user's point of view, never the implementer's.
4. Commit `.claude/settings.json` when runs need pre-approved permissions or hooks.
5. Each `CLAUDE.md` ends with a "What done looks like" verification gate.
