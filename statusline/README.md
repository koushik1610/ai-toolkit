# statusline

One-line Claude Code status bar, 24-bit color: repo name, git branch, a 20-block
context-usage bar (green to red gradient), 5h and weekly rate-limit bars, code
velocity, lines changed, model, and session cost. Reads the status JSON on stdin.

```
myrepo | 🌿 (main) | 🔥 ████████████░░░ 78% | 5h ███ 34% (in 1h 0m) | 7d █████ 61% (in 4d 0h) | ⚡52 ln/m | +142 -37 | 🤖 Opus 4.8 | $1.23
```

## Files

- `statusline.sh`: bash version. macOS, Linux, or WSL. Needs `bash`, `jq`, `git`.
- `statusline.py`: Python version, same output, no `jq` needed. Cross-platform on macOS,
  Linux, and Windows without WSL. Needs Python 3 and `git` on PATH.

Both render the identical line. Pick bash if you live in a shell; pick Python for a single
cross-platform script (and to avoid the `jq` dependency).

## Use it

`install.sh` symlinks both into `~/.claude/`. Point `settings.json` at whichever you prefer.

bash:

```json
"statusLine": { "type": "command", "command": "bash ~/.claude/statusline.sh" }
```

Python (any OS):

```json
"statusLine": { "type": "command", "command": "python3 ~/.claude/statusline.py" }
```

On Windows, use `"python C:\\Users\\you\\.claude\\statusline.py"`.

The 5h and 7d segments only render when Claude Code sends `rate_limits` in the JSON, so they
appear on plan accounts and stay hidden otherwise. The 🌿 branch shows only inside a git repo.
Velocity (lines changed per minute) shows once the session has a measured duration.

## Color bands

The context emoji and every percentage track usage: 🟢 under 20%, ⚡ 20-69%,
🔥 70-89%, 🚨 90%+. The bar fills green at the left, through yellow, to red on the right.
