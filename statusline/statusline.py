#!/usr/bin/env python3
"""ai-toolkit status line for Claude Code (Python, cross-platform).

One truecolor line: repo | branch | context bar | 5h + weekly limit bars | velocity |
lines +/- | model | session cost. Reads the Claude Code status JSON on stdin.

Cross-platform replacement for the PowerShell port: runs anywhere Python 3 + git are on
PATH, including Windows without WSL. No jq dependency.

Wire in settings.json:
  bash/macOS/Linux:  "command": "python3 $HOME/.claude/statusline.py"
  Windows:           "command": "python C:\\Users\\you\\.claude\\statusline.py"
"""
import json
import subprocess
import sys
import time


def fg(r, g, b):
    return f"\033[38;2;{r};{g};{b}m"


def bfg(r, g, b):
    return f"\033[1;38;2;{r};{g};{b}m"


RESET = "\033[0m"
YELLOW = fg(220, 200, 0)
GREEN = fg(0, 200, 80)
RED = fg(220, 40, 20)
MAGENTA = fg(200, 0, 200)
CYAN = fg(0, 180, 200)
DIM = fg(100, 100, 100)
PIPE = f"{DIM} | {RESET}"


def git(cur_dir, *args):
    try:
        out = subprocess.run(
            ["git", "-C", cur_dir, *args],
            capture_output=True, text=True, timeout=2,
        )
        return out.stdout.strip() if out.returncode == 0 else ""
    except Exception:
        return ""


def gradient_bar(pct, n):
    """Green -> yellow -> red per-block gradient, identical to statusline.sh."""
    half = n // 2
    filled = round(pct * n / 100)
    filled = max(0, min(n, filled))
    out = ""
    for i in range(n):
        if i < filled:
            if i < half:
                r, g, b = 220 * i // half, 200, 80 - 80 * i // half
            else:
                j = i - half
                r, g, b = 220, 200 - 160 * j // half, 20 * j // half
            out += fg(r, g, b) + "█"
        else:
            out += fg(60, 60, 60) + "█"
    return out + RESET


def pct_color(p):
    x = round(p)
    if x >= 90:
        return fg(220, 40, 20)
    if x >= 70:
        return fg(220, 120, 20)
    if x >= 20:
        return fg(220, 200, 0)
    return fg(0, 200, 80)


def format_reset(ts):
    diff = int(ts) - int(time.time())
    if diff <= 0:
        return "now"
    mins = diff // 60
    hours = mins // 60
    days = hours // 24
    if days >= 1:
        return f"in {days}d {hours % 24}h"
    if hours >= 1:
        return f"in {hours}h {mins % 60}m"
    return f"in {mins}m"


def get(d, *path, default=None):
    for k in path:
        if not isinstance(d, dict):
            return default
        d = d.get(k)
        if d is None:
            return default
    return d


def main():
    raw = sys.stdin.read()
    if not raw.strip():
        return
    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        return

    model = get(data, "model", "display_name", default="Claude")
    cur_dir = get(data, "workspace", "current_dir") or get(data, "cwd") or "."
    used = float(get(data, "context_window", "used_percentage", default=0) or 0)
    cost = float(get(data, "cost", "total_cost_usd", default=0) or 0)
    added = int(get(data, "cost", "total_lines_added", default=0) or 0)
    removed = int(get(data, "cost", "total_lines_removed", default=0) or 0)
    dur_ms = float(get(data, "cost", "total_duration_ms", default=0) or 0)
    five_pct = get(data, "rate_limits", "five_hour", "used_percentage")
    five_reset = get(data, "rate_limits", "five_hour", "resets_at")
    week_pct = get(data, "rate_limits", "seven_day", "used_percentage")
    week_reset = get(data, "rate_limits", "seven_day", "resets_at")

    top = git(cur_dir, "rev-parse", "--show-toplevel")
    repo = top.split("/")[-1].split("\\")[-1] if top else cur_dir.rstrip("/\\").split("/")[-1]
    branch = git(cur_dir, "branch", "--show-current") or git(cur_dir, "rev-parse", "--short", "HEAD")

    pct_int = round(used)
    emoji = "\U0001F6A8" if pct_int >= 90 else "\U0001F525" if pct_int >= 70 else "⚡" if pct_int >= 20 else "\U0001F7E2"

    velocity = round((added + removed) / (dur_ms / 60000)) if dur_ms > 0 else 0

    parts = [bfg(220, 200, 0) + repo + RESET]
    if branch:
        parts.append(bfg(0, 180, 200) + f"\U0001F33F ({branch})" + RESET)
    parts.append(f"{emoji} {gradient_bar(used, 20)} {pct_color(used)}{pct_int}%{RESET}")

    if five_pct not in (None, ""):
        fp = round(float(five_pct))
        rst = f" {DIM}({format_reset(five_reset)}){RESET}" if five_reset else ""
        parts.append(f"{DIM}5h{RESET} {gradient_bar(float(five_pct), 10)} {pct_color(float(five_pct))}{fp}%{RESET}{rst}")
    if week_pct not in (None, ""):
        wp = round(float(week_pct))
        rst = f" {DIM}({format_reset(week_reset)}){RESET}" if week_reset else ""
        parts.append(f"{DIM}7d{RESET} {gradient_bar(float(week_pct), 10)} {pct_color(float(week_pct))}{wp}%{RESET}{rst}")

    if velocity > 0:
        parts.append(f"{CYAN}⚡{velocity} ln/m{RESET}")
    parts.append(f"{GREEN}+{added}{RESET} {RED}-{removed}{RESET}")
    parts.append(f"{MAGENTA}\U0001F916 {model}{RESET}")
    parts.append(f"{YELLOW}${cost:.2f}{RESET}")

    sys.stdout.write(PIPE.join(parts))


if __name__ == "__main__":
    main()
