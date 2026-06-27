---
name: security-council
description: Multi-persona security deliberation panel. Convenes 9 specialized security personas to independently analyze a proposal, then synthesizes a structured verdict with confidence score and actionable conditions. Use for architecture decisions, new features touching security-sensitive code, threat model reviews, or any change where a single perspective is insufficient.
---

# Security Council

Thin wrapper. This council is an instance of the **llm-council** engine running the
**security** preset.

## How to run

1. Invoke the `llm-council` skill (the engine).
2. Load its security config: `llm-council/councils/security.md`. That config defines the 9
   personas (RED, BLUE, STRAT, AI-SEC, PREV, ADV, COMP, CAT, OPS), the 3-phase protocol, the
   `disposition` verdict format, the AI-SEC mandatory rule, and the hard-deny gate.
3. Follow the engine's run steps with that config. Default mode is full; `--quick` runs
   Phase 1 only (abbreviated), with AI-SEC still mandatory on LLM-touching changes.

The persona definitions live in `llm-council/personas/` (the security callsigns) and the
output format in `llm-council/verdicts.md` §2. Output is the `SECURITY COUNCIL — FINAL
VERDICT` block.

## Inputs

A proposal, a question, a finding, or a file/code block to evaluate. Optional `--quick` and
`--personas <subset>`.

> Do not convene for typo fixes, pure UI changes with no data flow, or questions already
> answered by an existing policy rule.
