# statusline

One-line Claude Code status bar, 24-bit color: repo name, git branch, a 20-block
context-usage bar (green to red gradient), 5h and weekly rate-limit bars, code
velocity, model, and session cost. Reads the status JSON on stdin.

```
myrepo | 🌿 (main) | 🔥 ████████████░░░ 78% | 5h ███ 34% (in 1h 0m) | 7d █████ 61% (in 4d 0h) | +142 -37 | 🤖 Opus 4.8 | $1.23
```

## Files

- `statusline.sh` — the original. macOS, Linux, or WSL. Needs `bash`, `jq`, `git`.
- `statusline.ps1` — PowerShell port for Windows without WSL, where PowerShell can't
  run bash. Same output. Needs `pwsh` (PowerShell 7+) and `git`.

> Adopted the bash version, wanted it on Windows without WSL. Same bar, ported to
> PowerShell. Leaving it here in case it's useful to someone else.

## Use it

Copy your script of choice to `~/.claude/` and point `settings.json` at it.

bash:

```json
"statusLine": { "type": "command", "command": "bash ~/.claude/statusline.sh" }
```

PowerShell:

```json
"statusLine": {
  "type": "command",
  "command": "pwsh -NoProfile -File C:\\Users\\you\\.claude\\statusline.ps1"
}
```

The 5h and 7d segments only render when Claude Code sends `rate_limits` in the JSON,
so they appear on plan accounts and stay hidden otherwise. The 🌿 branch shows only
inside a git repo.

## Color bands

The context emoji and every percentage track usage: 🟢 under 20%, ⚡ 20-69%,
🔥 70-89%, 🚨 90%+. The bar fills green at the left, through yellow, to red on the right.
