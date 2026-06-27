---
description: Convene the llm-council on an ask, design, or project and save the prioritized verdict to a dated file.
argument-hint: "[--lite|--full] [--vote|--no-vote] [--council <preset>] <what to review>"
---

# /council

Run the `llm-council` engine over whatever follows and write the verdict to a file so it's
not lost in the scrollback.

## Steps

1. Parse `$ARGUMENTS`:
   - `--lite` (default) or `--full`
   - `--vote` / `--no-vote` (default: off in lite, on in full)
   - `--council <preset>` to use a preset from `llm-council/councils/` (e.g. `security`).
     If omitted, the engine selects personas to fit the ask.
   - everything else is the review target (an ask, a path, or "the whole project").
2. Invoke the `llm-council` skill with those options. Follow its run steps.
3. After synthesis, save the full verdict to
   `council-reviews/<YYYY-MM-DD>-<short-slug>.md` in the current project (create the dir if
   needed), and print the path. Keep the inline reply to the summary + P0 items.

## Notes

- For a quick gut-check use `--lite`; for high-stakes or whole-project reviews use `--full`.
- To review code security specifically, `/council --council security <target>`.
- The saved file is git-ignorable; it's a working artifact, not a deliverable.
