# Anonymous peer vote (Karpathy-style)

Runs in full mode when voting is on. Surfaces genuine disagreement and reprioritizes by the
council's collective judgment, without anchoring on who said what.

## Protocol

1. **Anonymize.** The Chairman strips persona identities from all Phase 1 findings and
   presents them as a flat list: Finding A, Finding B, Finding C, …

2. **Re-vote on own position.** Each persona reviews the anonymized set and either:
   - **HOLD** — keeps its original position, or
   - **UPDATE** — changes it, with a one-sentence reason. Update only on **new information
     or a better argument**, never on social pressure or perceived majority.

3. **Rank others' findings.** Each persona ranks the findings it did *not* author by
   importance (most → least). It may also mark a finding as *disputed* with a one-line reason.

4. **Aggregate.** The Chairman tallies the rankings into a vote weight per finding
   (e.g. Borda count: a finding ranked 1st by a persona scores N-1, 2nd scores N-2, …,
   summed across personas). Disputed flags are noted, not subtracted — dissent is preserved.

## How votes shape the verdict

- **priority format:** vote weight sets the order within and across P0/P1/P2. A finding many
  personas ranked highly rises; a fringe finding sinks but is not deleted.
- **disposition format:** votes inform the consensus label (UNANIMOUS / MAJORITY n-of-N /
  SPLIT) and the weighted confidence. They do **not** override a hard-deny gate.
- **score format:** scoring is numeric and per-member, so voting is usually off; when on, it
  only reorders the written findings, never changes a member's number or the gate.

## Rules

- Votes are anonymous. Never reveal which persona authored or ranked a finding in the vote
  phase.
- A single persona's strong dissent always survives into the synthesis dissent section.
- Voting never overrides hard gates (hard-deny lists, score floors).
