---
description: Remove AI-generated tells from a file or the current diff using the ai-deslop ruleset.
argument-hint: "[--flag] [<file path> | (no arg = current git diff)]"
---

# /deslop

Run the `ai-deslop` skill over a target and clean (or flag) the AI tells.

## Steps

1. Parse `$ARGUMENTS`:
   - `--flag` → flag-only mode (list violations, don't rewrite).
   - a file path → deslop that file.
   - no path → deslop the prose in the current uncommitted git diff (added lines only;
     skip code, format only human-facing text).
2. Invoke the `ai-deslop` skill; read its `rules.md` first.
3. Apply: rewrite in place (default) or list violations (`--flag`). Preserve meaning and any
   genuine voice; remove only the slop. Don't make it longer, don't add a summary.
4. Report what changed, grouped by rule (em-dashes removed, filler cut, etc.). Keep it short.

## Notes

- Targets human-facing prose only: docs, READMEs, posts, emails, commit bodies, comments.
- Never introduces an em-dash.
