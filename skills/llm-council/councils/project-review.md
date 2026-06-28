# Council config: project-review (general)

The default general-purpose council. Reviews an ask, a design, or a whole project from a
balanced set of engineering and delivery lenses and returns prioritized fixes. This is the
config to copy when starting a new council.

## Mode & format

- **Mode default:** full (9 personas + voting). Use `--lite` for a 3-persona gut-check.
- **Verdict format:** `priority` (P0 / P1 / P2). See [../verdicts.md](../verdicts.md) §1.
- **Voting:** on in full (reprioritizes findings by vote weight).
- **Council name in output:** `COUNCIL`.

## Personas

**Full (9), from the shared library:**
`software-engineer`, `systems-engineer`, `cybersecurity`, `cloud-security`,
`project-manager`, `pragmatist`, `realist`, `devils-advocate`, plus one slot chosen to fit
the ask (e.g. `ai-security` if it touches an LLM, `compliance` if regulated data).

**Lite (3):** pick the 3 most relevant lenses for the ask; always include `pragmatist` or
`devils-advocate` as the skeptic.

## Groups (parallel agents, full mode)

- **Build quality**: software-engineer, systems-engineer, (ai-security if seated)
- **Security & risk**: cybersecurity, cloud-security, (compliance if seated)
- **Delivery & reality**: project-manager, pragmatist, realist, devils-advocate

## Gate

No numeric gate by default. The output is advisory: P0 must be addressed before shipping,
P1 should be, P2 is optional. If any seated security persona fires a hard-gate trigger
(see their persona files), surface it as a blocking P0.

## When to use

"Review this project / design / ask." Architecture and approach decisions. Anything where you
want multiple expert lenses and a prioritized to-do, rather than a single opinion.
