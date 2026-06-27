# Archetype: web-frontend

A Next.js / React frontend or portfolio (modeled on the koushik.io portfolio).

**Seeded hard rules (into CLAUDE.md §3):**
- Pin the fonts, the animation library, and the styling system; never mix two animation owners
  on the same property of the same element.
- Design tokens first; no one-off component styles.
- Keep components small with clear boundaries so AI tools can extend them without regressions.
- WCAG AA: contrast, keyboard flows, visible focus states.

**Extra rule files (into .claude/rules/):**
- `design-system.md` — tokens, typography, spacing scale, motion rules.
- `code-style.md` — component structure, file organization.

**Settings additions:** allow `npm run`, the dev server, and Playwright.

**Suggested review gate:** run the `portfolio-design-council` (≥95 composite, no member <80)
before committing visual changes.

**Verification gate (CLAUDE.md §5):** build is green, the page renders, and the design council
gate passes for visual work.
