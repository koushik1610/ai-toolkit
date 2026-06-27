# Archetype: mcp-server

A Model Context Protocol server (modeled on medium-mcp-server).

**Seeded hard rules (into CLAUDE.md §3):**
- Lazy/once init for expensive resources (browser, auth session); share via a single Promise.
- Tools are small and composable; shared logic lives in a utilities module, not copied per tool.
- Session/credential handling is centralized and never logged.
- Each tool validates its inputs and returns structured errors, not exceptions.

**Extra rule files (into .claude/rules/):**
- `mcp-conventions.md` — tool registration, naming, error shape, session lifecycle.

**Settings additions:** allow `node`, the test runner, and the MCP inspector command.

**Verification gate (CLAUDE.md §5):** server registers, tools list, and a representative tool
call succeeds against the inspector.
