# Persona library

One file per persona. These are the **reusable** personas: general-purpose lenses plus the
security callsigns. Domain-specific one-off personas (e.g. the portfolio design/resume
members) live inline in their `councils/*.md` config instead of here.

## Schema

```markdown
# {Persona name}

**Callsign:** {SHORT}            <!-- optional, used in disposition output -->
**Lens:** {one line, the angle this persona reviews from}

**Obsessed with:** {what they prioritize / what "good" means to them}
**Biases:** {what they reflexively distrust or push back on}
**Reviews (asks):**
- {question this persona always asks of the work}
- {another}

**Score rubric (score format only):** 95+ = {elite}; 80–94 = {ok}; <80 = {failing}
**Hard-gate triggers (if any):** {conditions this persona can fire that force a REJECT}
**Mandatory when:** {optional, when this persona must always be seated}
```

Only `name`, `Lens`, `Obsessed with`, `Biases`, and `Reviews` are required. The rest apply
depending on the verdict format the council uses.

## Current personas

General: software-engineer, systems-engineer, cybersecurity, cloud-security, pragmatist,
realist, project-manager, devils-advocate.

Security callsigns: red-offense, blue-defense, strategy-analyst, ai-security,
prevention-engineer, compliance, threat-catalog, security-ops.

Add more by dropping in a file that follows the schema.
