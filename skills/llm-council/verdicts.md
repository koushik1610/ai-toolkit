# Verdict formats

A council config picks one. The engine renders the synthesis (Phase 3) in this format.

---

## 1. `priority`: P0 / P1 / P2 (default, general review)

For reviewing an ask or a whole project. Findings are bucketed by priority and, when voting
ran, ordered within each bucket by vote weight.

```
═══════════════════════════════════════
COUNCIL VERDICT: {subject}
Mode: {lite|full}  ·  Personas: {list}  ·  Voting: {on|off}
═══════════════════════════════════════

── Summary ────────────────────────────
{2–3 sentences: overall state and the single most important thing to do}

── P0: must fix / blocking ───────────
1. {finding}: {why it matters}, {specific action}  [raised by {persona}]
2. ...

── P1: should fix ────────────────────
1. {finding}: {action}  [raised by {persona}]

── P2: nice to have ──────────────────
1. {finding}: {action}

── Dissenting view ────────────────────
{strongest minority position, even if outvoted}

── What "good" looks like ─────────────
{the bar this would clear once P0/P1 are addressed}
═══════════════════════════════════════
```

P0 = correctness/security/blocking; P1 = important but shippable-around; P2 = polish.

---

## 2. `disposition`: APPROVE / CONDITIONAL / REJECT / DEFER (security-style)

For go/no-go gates. Each persona gives a disposition + confidence; the Chairman synthesizes.

Per-persona (Phase 1):
```
[CALLSIGN] {DISPOSITION} | Confidence: {N}%
{2–4 sentences of reasoning}
Conditions (if CONDITIONAL): {bullets}
```

Dispositions: **APPROVE** (safe as-is), **CONDITIONAL** (approve if conditions met),
**REJECT** (do not ship), **DEFER** (insufficient info: list what's needed),
**DEPRECATE** (existing pattern should be removed).

Confidence clamped **55–95%**. Never 100% (human in loop); never below 55% (→ DEFER).

Final report:
```
═══════════════════════════════════════
{COUNCIL NAME}: FINAL VERDICT
═══════════════════════════════════════
Proposal: {title}        Date: {date}
VERDICT: {APPROVE | CONDITIONAL | REJECT | DEFER}
Consensus: {UNANIMOUS | MAJORITY n_OF_N | SPLIT n_FOR / m_AGAINST / k_CONDITIONAL}
Council Confidence: {weighted avg, clamped 55–95}%

── Summary ────────────────────────────
── Conditions (if CONDITIONAL) ────────  {specific, actionable, verifiable}
── Dissenting View ────────────────────  {strongest opposing argument}
── Hard Deny Gate ─────────────────────  {from config; Gate triggered: YES, reason | NO}
── Mapping (if applicable) ────────────  {MITRE ATT&CK / CWE / etc.}
── Required Before Ship ───────────────  {checklist from CONDITIONAL personas + gate}
═══════════════════════════════════════
```

Hard-deny gate (defined per config) fires REJECT regardless of vote.

---

## 3. `score`: numeric 0–100 with composite + floor gate (portfolio-style)

For quality bars where each member scores independently. Run as parallel group agents.

Per member:
```
{Member name}: {0–100}
  Findings: {top 2–3 specific observations}
  Improve:  {concrete suggestions}
```

Per group: `Group composite = mean of group member scores.`

Final:
```
═══════════════════════════════════════
{COUNCIL NAME}: SCORECARD
═══════════════════════════════════════
{Group 1}: {composite}
{Group 2}: {composite}
{Group 3}: {composite}

FINAL COMPOSITE = mean of all {N} member scores = {value}
GATE: ≥{composite_min} composite AND no member <{floor}
RESULT: {PASS | FAIL, {which members/composite missed and by how much}}

── Top fixes to clear the gate ────────
{ordered list of what would move the lowest scores}
═══════════════════════════════════════
```

Gate thresholds (`composite_min`, `floor`) come from the config.
