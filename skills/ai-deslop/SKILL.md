---
name: ai-deslop
description: Remove AI-generated tells from prose so it doesn't read as machine-written. Use when the user asks to "deslop" text, before publishing or sending human-facing writing (READMEs, docs, posts, emails, commit bodies), or when prose has em-dashes, corporate filler, or chatbot tone. Does not apply to code.
---

# ai-deslop

Strip the tells that make writing read as AI-generated. The full ruleset is in
[rules.md](rules.md). Read it before deslopping.

## When to use

- The user says "deslop this", "make this not sound like AI", "remove the AI tells".
- Before producing or finalizing any human-facing prose (README, doc, blog/Medium/Substack
  post, email, PR description, commit body).
- When reviewing text that has em-dashes, "it's not just X it's Y", "delve/leverage/robust",
  emoji headers, or three-item lists everywhere.

## How to run

1. **Read [rules.md](rules.md).** It is the source of truth and grows over time.
2. **Scan** the target text against each rule category: punctuation (em-dashes first),
   banned constructions, banned vocabulary, tone/rhythm, formatting tells.
3. **Rewrite in place.** Preserve the author's meaning and any genuine voice; remove only
   the slop. Don't make it longer. Don't add a summary.
4. **Report** what you changed, grouped by rule (e.g. "removed 4 em-dashes; cut 2 'leverage';
   broke up 3 same-length sentences"). Keep the report short.

## Modes

- **Rewrite (default):** return the cleaned text.
- **Flag-only** (`--flag`): list the violations with line references and suggested fixes,
  but don't rewrite. Use when the user wants to keep control of the edit.

## Hard rule

Never introduce an em-dash. If you're about to write "—", stop and restructure the sentence.

## Note

This skill is also wired as always-on guidance: `install.sh` adds an import of `rules.md`
to the global `~/.claude/CLAUDE.md`, so the rules bias every response, not just explicit
deslop requests. The skill is for deliberate passes over a specific piece of text.
