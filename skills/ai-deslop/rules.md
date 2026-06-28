# ai-deslop rules

The ruleset for prose that should not read as AI-generated. Applies to anything a human
will read: docs, READMEs, commit bodies, posts, emails, comments. Does not apply to code.

This file is meant to grow. Add a rule whenever a new tell shows up.

## Punctuation

- **No em-dashes (—).** Rewrite with a period, comma, parentheses, or colon. This is the
  single strongest AI tell. Also avoid the spaced en-dash ( – ) used the same way.
- No "—" even where it would be grammatically fine. Just restructure.
- Don't overuse semicolons to glue clauses that want to be two sentences.
- Avoid the "curly-quote everything" look if the surrounding text uses straight quotes.

## Banned constructions

- **"It's not just X, it's Y."** And its cousins: "It's not about X. It's about Y.",
  "This isn't X — it's Y." Delete the setup, state the point.
- **"More than just…"**, **"At its core…"**, **"In a world where…"**, **"In today's
  fast-paced…"**, **"When it comes to…"**.
- **Rule of three everywhere** ("fast, reliable, and scalable"). Vary list length; one
  strong adjective beats three weak ones.
- **"Let's dive in" / "Let's explore" / "Buckle up."** Just start.
- Closing summaries that restate what was already said ("In conclusion, …").
- "I hope this helps!" / "Feel free to…" / "Happy to help" filler.

## Banned/flagged words (corporate-LLM vocabulary)

delve, leverage (as verb), robust, seamless, seamlessly, elevate, unlock, harness,
empower, streamline, foster, facilitate, utilize (→ use), plethora, myriad, tapestry,
realm, landscape (figurative), ecosystem (figurative), bustling, testament, navigate
(figurative), embark, journey (figurative), game-changer, cutting-edge, state-of-the-art,
best-in-class, supercharge, turbocharge, paradigm, holistic, synergy, vibrant.

Not absolute bans, but each occurrence should justify itself. Default to the plain word.

## Tone & rhythm

- **Vary sentence length.** AI writes medium-medium-medium. Mix short punches with longer
  lines. A three-word sentence is allowed.
- Cut hedging stacks: "it's worth noting that", "it's important to remember that",
  "generally speaking", "in many cases", usually deletable.
- No false precision or invented confidence. If unsure, say so plainly.
- Prefer concrete nouns and verbs over abstractions. Show the thing, don't gesture at it.
- Don't over-explain the obvious or pad to hit a length.

## Formatting tells

- Don't bold a phrase at the start of every bullet as a fake "header: explanation" pattern
  unless it genuinely helps scanning.
- No emoji in section headers (✨ 🚀 💡). No emoji bullets unless the user uses them.
- Don't title-case-everything headers in a way the surrounding doc doesn't.
- Avoid "Here's the thing:" and "The bottom line:" as paragraph openers.

## The test

Read it aloud. If it sounds like a press release, a LinkedIn thought-leadership post, or a
chatbot being helpful, it's slop. Rewrite until it sounds like a competent person who has
better things to do than impress you.
