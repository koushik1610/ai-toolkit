# Archetype: startup-rag

A security-first RAG / LLM product (modeled on project-onyx). Assumes an LLM call path,
retrieved documents, PII, and a need for review gates.

**Seeded hard rules (into CLAUDE.md §3):**
- Untrusted/retrieved content is never mixed with instructions in the prompt without isolation.
- Model output is untrusted by default; never flows to a sensitive sink (SQL/shell/eval) unchecked.
- PII is redacted before crossing any boundary, and never logged.
- The `security-council` gate runs before changes to the document boundary, PII redaction, or
  prompt construction.

**Extra rule files (into .claude/rules/):**
- `security.md` — trust boundaries, secret handling, the hard-deny gate items.
- `ai-security.md` — prompt-injection, RAG-poisoning, output-handling rules.
- `compliance.md` — DPDP / sector confidentiality, retention, audit.

**Settings additions:** allow the project's test/format commands; wire a PostToolUse format
hook if the stack needs one.

**Suggested .claude/ extensions:** an `inbox-processor` agent and a `security-reviewer` agent,
mirroring project-onyx.
