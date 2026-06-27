---
name: llm-council
description: Configurable multi-persona review council. Convenes a panel of personas (software engineer, systems engineer, cybersecurity, cloud security, pragmatist, realist, project manager, and more) to review an ask, a design, or an entire project, then synthesizes a prioritized verdict. Supports lite (3 personas, no vote) and full (9–10 personas, anonymous voting) modes, and priority / disposition / score verdict formats. Use to review a proposal or project from multiple expert perspectives in one pass. Preset councils (security, portfolio-design, portfolio-resume) are derived from this engine.
---

# LLM Council

A reusable engine for running a panel of expert personas over an ask or a project and
producing one synthesized, prioritized verdict. Personas, mode, voting, and verdict format
are all configurable. Existing councils (`security-council`, `portfolio-design-council`,
`portfolio-resume-council`) are thin wrappers that call this engine with a preset config.

Read these companion files as needed:
- [modes.md](modes.md) — lite vs full, how personas are chosen
- [voting.md](voting.md) — the anonymous peer-vote protocol
- [verdicts.md](verdicts.md) — priority / disposition / score output formats
- [personas/](personas/) — the reusable persona library, one file per persona
- [councils/](councils/) — preset council configs

## Inputs

The user provides what to review (a proposal, a question, a file/dir, or "the whole
project") plus, optionally:

- **Council preset:** a config from `councils/` (e.g. `--council security`). If a wrapper
  skill invoked the engine, the preset is already chosen.
- **Mode:** `--lite` (default) or `--full`. See [modes.md](modes.md).
- **Voting:** `--vote` / `--no-vote`. Default: off in lite, on in full.
- **Personas:** `--personas a,b,c` to override which personas speak. If omitted and no
  preset is given, the engine **selects personas to fit the ask** (see below).

## How to run a council

Follow these steps in order. Announce the chosen mode, personas, and verdict format up front.

### Step 1 — Resolve the configuration

1. If a council preset is given, load `councils/<name>.md`. It specifies personas, mode
   default, verdict format, gates, and any mandatory personas. Its instructions win.
2. Otherwise, pick the **mode** (lite unless the ask is high-stakes or the user said full)
   and **select personas**:
   - Read the ask. Choose personas from `personas/` whose lens actually applies.
   - Lite = exactly 3. Full = 9–10. Always include at least one skeptic
     (`pragmatist` or `devils-advocate`).
   - A preset may pin **mandatory personas** that must always speak (e.g. `ai-security`
     on anything touching an LLM call path).
3. Pick the **verdict format** ([verdicts.md](verdicts.md)): `priority` (P0/P1/P2) is the
   default for general review; presets may force `disposition` or `score`.

### Step 2 — Phase 1: Independent analysis

Spawn the personas to analyze the input **in isolation** (no cross-talk). For full mode,
group personas and dispatch parallel agents (one agent embodies a group, scores/assesses
each member separately) — this is how the preset councils run. For lite mode, a single pass
embodying the 3 personas is fine.

Each persona, in its own voice and lens (from its `personas/*.md` file), produces findings
in the configured verdict format. A persona only raises what falls in its lens.

### Step 3 — Phase 2: Anonymous peer vote (full mode, if voting on)

Strip persona identities; present each finding as "Finding A, B, C…". Each persona reviews
all findings and votes per [voting.md](voting.md): HOLD or UPDATE their own position, and
rank others' findings by importance. Votes are aggregated to reprioritize. Lite mode and
`--no-vote` skip this step.

### Step 4 — Phase 3: Synthesis

The Chairman (synthesis role, not a voting persona) produces the final report in the
configured verdict format:
- **priority:** findings grouped into P0 / P1 / P2, ordered by vote weight when voting ran.
- **disposition:** APPROVE / CONDITIONAL / REJECT / DEFER + clamped confidence + hard-deny gate.
- **score:** per-member 0–100, group composites, final composite, gate check.

Always include a **dissenting view** (the strongest minority position), even on consensus.
Apply any **hard gates** from the preset — these cannot be overridden by vote.

## Guardrails

- Never suppress a minority view. A lone REJECT or a single low score still appears.
- Findings/conditions must be **actionable and specific**, never "improve quality".
- Hard gates (hard-deny lists, score floors) override the vote.
- Personas stay in their lens. Don't have the project manager review crypto internals.
- No false precision. If the input is ambiguous, say so; disposition = DEFER, or note the
  gap in the priority/score output.

## Extending

- **Add a persona:** drop a new file in `personas/` using the schema in
  [personas/README.md](personas/README.md). It's immediately usable via `--personas`.
- **Add a council:** add a config in `councils/` listing personas + mode + verdict + gates.
  Optionally add a thin wrapper skill so it has its own invocation name.
