# ai-toolkit

A curated collection of agents, prompts, hooks, commands, rules, and workflows for
AI-assisted engineering. Tools for setting up my workspace and projects for AI development.
The repo is the source of truth; `install.sh` symlinks the skills and commands into
`~/.claude`, so edits here take effect immediately.

## Contents

| Tool | What it does |
|------|--------------|
| **conventions/** | The project-structure standard: routing `CLAUDE.md` (<150 lines), `WORKFLOW.md` (user stories), and the per-project memory layer. Templates included. |
| **skills/ai-deslop/** | Removes AI-generated tells from prose (no em-dashes, no corporate filler, no chatbot tone). On-demand skill + always-on rules imported into the global `CLAUDE.md`. |
| **skills/llm-council/** | Configurable multi-persona review council. Lite (3 personas) / full (9–10 + anonymous voting), with priority / disposition / score verdicts. Personas are a composable library. |
| **skills/*-council/** | `security-council`, `portfolio-design-council`, `portfolio-resume-council` — thin wrappers that run the llm-council engine with a preset. |
| **commands/** | `/bootstrap` (scaffold a project), `/council` (convene the council, save the verdict), `/deslop` (clean a file or diff). |
| **agents/** | Curated subagents: `security-reviewer`, `simplifier`. |
| **hooks/** | `stop-memory-reminder` (nudge memory updates), `pretooluse-guard` (block destructive commands + secrets), `sessionstart-context` (load recent memory + git state), `posttooluse-format` (auto-format by extension, opt-in). |
| **archetypes/** | Bootstrap presets: `generic`, `startup-rag`, `mcp-server`, `single-tool`, `web-frontend`. |
| **statusline/** | One-line truecolor status bar (repo, branch, context bar, 5h/weekly limits, velocity, model, cost). `statusline.sh` (bash) and `statusline.py` (Python, cross-platform, no `jq`). |
| **tests/** | `bats` tests for install/uninstall/doctor, the guard, and the statusline; `shellcheck` + Python compile in CI. |

## Install

```bash
git clone git@github.com:koushik1610/ai-toolkit.git ~/Code/ai-toolkit
cd ~/Code/ai-toolkit
./install.sh        # symlinks skills+commands, wires the Stop hook, imports ai-deslop rules
```

`install.sh` is idempotent and backs up anything real it would replace (into
`~/.claude/.ai-toolkit-backups/`). Use `./install.sh --dry-run` to preview, `./doctor.sh` to
check health, and `./uninstall.sh` to reverse it. Requires `jq` for the settings.json merge
(falls back to printing manual instructions).

Installing wires two **global** hooks: a `Stop` memory nudge and a `PreToolUse` guard that
blocks destructive commands and obvious secrets. Bypass the guard for one call with
`AI_TOOLKIT_GUARD=off`. It's a speed bump, not a replacement for git pre-commit secret scanning.

## The council, briefly

A council is a panel of personas reviewing an ask or a project. Personas live one-per-file in
`skills/llm-council/personas/`. A *council config* (`skills/llm-council/councils/*.md`) picks
personas, a mode, a verdict format, and any gates. The existing security and portfolio
councils are configs of this one engine, so improving the engine improves all of them.

- **Lite:** 3 personas, no vote, fast. **Full:** 9–10 personas, anonymous peer vote, synthesis.
- **Verdicts:** `priority` (P0/P1/P2, default), `disposition` (APPROVE/CONDITIONAL/REJECT +
  confidence), `score` (0–100 with composite + floor gate).

See [skills/llm-council/SKILL.md](skills/llm-council/SKILL.md).

## Project structure standard

See [conventions/PROJECT-STRUCTURE.md](conventions/PROJECT-STRUCTURE.md). The short version:
`CLAUDE.md` routes, it does not dump. Detail lives in `.claude/rules/*.md`, user stories in
`WORKFLOW.md`, architecture in `docs/`. Run `/bootstrap` to scaffold it.
