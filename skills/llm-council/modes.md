# Council modes

## Lite

- **Personas:** exactly 3, chosen to fit the ask. Always include one skeptic.
- **Phases:** single pass (independent analysis → synthesis). No peer vote.
- **Verdict:** priority (P0/P1/P2) unless the preset forces otherwise.
- **Use for:** quick gut-checks, small asks, early-stage ideas, fast turnaround.
- **Cost:** one set of perspectives, no parallel agents required.

## Full

- **Personas:** 9–10, chosen to fit the ask (presets pin their own roster). Include the
  required skeptic and any mandatory personas.
- **Phases:** independent analysis → anonymous peer vote ([voting.md](voting.md)) → synthesis.
- **Execution:** group the personas (3 groups is typical) and dispatch **parallel agents**,
  each embodying its group and assessing every member separately. This matches how the
  preset councils (security, portfolio) run.
- **Verdict:** the preset's format (priority / disposition / score).
- **Use for:** high-stakes decisions, whole-project reviews, anything shipping to prod,
  security/compliance gates.

## Choosing personas for the ask

When no preset roster is given, select from `personas/` by relevance:

1. Identify the dimensions the ask actually has (code quality? security? cost? UX? delivery
   risk? data/privacy?).
2. Pick the personas whose lens covers each live dimension.
3. Always add a skeptic (`pragmatist` or `devils-advocate`).
4. Trim to 3 (lite) or 9–10 (full). Prefer breadth of lens over redundant viewpoints.
5. State the chosen roster and why before running.
