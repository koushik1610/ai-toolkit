# Archetype: single-tool

A focused single-purpose tool or bot (modeled on flight-hunter). Optimized against
over-abstraction.

**Seeded hard rules (into CLAUDE.md §3):**
- No premature abstraction. One tool, one job; don't build a framework.
- Declare what NOT to change (e.g. "don't swap the model", "no new dependencies for one feature").
- Async by default where I/O-bound; keep the data model in one place.
- Secrets in env, never in code or logs.

**Extra rule files (into .claude/rules/):**
- `lessons-learned.md`: running list of gotchas specific to this tool.

**Settings additions:** allow the run command and the test runner.

**Verification gate (CLAUDE.md §5):** the tool starts and its primary command/flow responds
correctly end to end.
