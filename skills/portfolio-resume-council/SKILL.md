---
name: portfolio-resume-council
description: 15-member Resume & Career Positioning Council for Koushik Kotamraju. Reviews resumes, LinkedIn, and portfolio content. Gate rule: ≥95 composite, no member below 80.
---

# Resume & Career Positioning Council

Thin wrapper. This council is an instance of the **llm-council** engine running the
**portfolio-resume** preset.

## How to run

1. Invoke the `llm-council` skill (the engine).
2. Load its config: `llm-council/councils/portfolio-resume.md`. That config defines the 15
   members, the 3 parallel groups (Strategy+Content / Technical+Domain / Brand+Channels), the
   subject dossier (metrics, keywords, target roles/companies), the `score` verdict format,
   the gate (**≥95 composite, no member <80**), the post-approval deliverables, and the
   positioning principles.
3. Follow the engine's run steps with that config: spawn 3 parallel group agents, each scores
   its members 0–100 with findings + improvements, then composite and gate-check. On ≥95,
   produce the three deliverables (Resume v1 Impact, Resume v2 Technical Depth, LinkedIn doc).

Output is the `RESUME & CAREER POSITIONING COUNCIL: SCORECARD` block
([llm-council/verdicts.md](../llm-council/verdicts.md) §3).
