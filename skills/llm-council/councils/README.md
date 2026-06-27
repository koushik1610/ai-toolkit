# Council presets

Each file is a council config consumed by the llm-council engine. A config specifies the
personas, mode, verdict format, gates, and any mandatory personas.

| Config | Personas | Verdict format | Gate | Wrapper skill |
|--------|----------|----------------|------|---------------|
| `project-review.md` | library, chosen to fit ask | priority (P0/P1/P2) | none (advisory) | — (engine default) |
| `security.md` | 9 security callsigns | disposition + confidence | hard-deny → REJECT | `security-council` |
| `portfolio-design.md` | 12 inline members | score 0–100 | ≥95 / floor 80 | `portfolio-design-council` |
| `portfolio-resume.md` | 15 inline members | score 0–100 | ≥95 / floor 80 | `portfolio-resume-council` |

## Add a council

1. Copy `project-review.md` as a starting point.
2. List personas (reference shared `personas/*.md`, or define domain-specific ones inline).
3. Pick the verdict format and any gate.
4. Optionally add a thin wrapper skill so it gets its own invocation name (see the wrapper
   skills under `~/.claude/skills/<name>-council/` — they just point the engine at a config).
