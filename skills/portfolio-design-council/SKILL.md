---
name: portfolio-design-council
description: 12-member UI+Design Council for koushik.io portfolio themes. Gate rule: ≥95 composite, no member below 80. Spawn 3 parallel agents, Visual, Engineering, UX+Systems groups.
---

# Portfolio UI + Design Council

Thin wrapper. This council is an instance of the **llm-council** engine running the
**portfolio-design** preset.

## How to run

1. Invoke the `llm-council` skill (the engine).
2. Load its config: `llm-council/councils/portfolio-design.md`. That config defines the 12
   members, the 3 parallel groups (Visual / Engineering / UX+Systems), the `score` verdict
   format, the distinctness rules, the reference portfolio pool, and the gate
   (**≥95 composite, no member <80**).
3. Follow the engine's run steps with that config: spawn 3 parallel group agents, each scores
   its members 0–100 with findings + improvements, then composite and gate-check.

Output is the `PORTFOLIO DESIGN COUNCIL: SCORECARD` block ([llm-council/verdicts.md](../llm-council/verdicts.md) §3).
Nothing commits to git until the gate passes.
