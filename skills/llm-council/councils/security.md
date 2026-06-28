# Council config: security

The security deliberation panel, expressed as a council config for the llm-council engine.
Drives the `security-council` wrapper skill. Preserves the original 3-phase, disposition-based
behavior.

## Personas (9)

From the library: `red-offense` (RED), `blue-defense` (BLUE), `strategy-analyst` (STRAT),
`ai-security` (AI-SEC), `prevention-engineer` (PREV), `devils-advocate` (ADV),
`compliance` (COMP), `threat-catalog` (CAT), `security-ops` (OPS).

The **Chairman** is the synthesis role (not a voting persona).

## Mode & format

- **Mode default:** full (9 personas, 3 phases). `--quick` runs Phase 1 only, abbreviated.
- **Verdict format:** `disposition` (APPROVE / CONDITIONAL / REJECT / DEFER + confidence).
  See [../verdicts.md](../verdicts.md) §2.
- **Voting:** Phase 2 anonymized peer review ([../voting.md](../voting.md)), HOLD/UPDATE,
  no numeric ranking needed (disposition format).
- **Confidence:** clamped 55–95%.
- **Council name in output:** `SECURITY COUNCIL`.

## Mandatory personas

- **AI-SEC always speaks** on any change touching the LLM call path, prompt construction, RAG
  pipeline, or model-output handling: even in `--quick` mode.

## Hard deny gate (overrides the vote → REJECT)

- Secrets hardcoded or logged
- PII crosses a boundary unredacted
- Authentication bypassed or absent at a new boundary
- Default-allow permission model
- External dependency touching document content without review

If any item triggers, VERDICT = REJECT regardless of council vote.

## Extra output section

- **ATT&CK / CWE Mapping**: populated when RED or CAT flag anything (CAT owns the mapping).

## When to convene

Architecture decisions affecting security posture; new code touching auth, data access,
encryption, or audit; third-party dependency/integration review; threat-modeling a new
attack surface; any go/no-go where one perspective is insufficient.

Do **not** convene for: typo fixes, pure UI changes with no data flow, questions already
answered by an existing policy rule.

## Context (Project Onyx and prior work)

For Onyx specifically: COMP always checks DPDP and Bar Council confidentiality; AI-SEC always
checks RAG poisoning and prompt injection. The pattern has gated detection signatures across
1,500+ and 2,800+ cloud accounts, the Onyx document boundary / PII redaction / prompt
construction, and OSINT source trust in the Threat Intelligence Synthesizer.
