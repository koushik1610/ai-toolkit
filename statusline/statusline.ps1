# Claude Code status line, PowerShell port of statusline.sh.
# For Windows without WSL, where PowerShell can't run the bash version.
# Same line: repo | branch | ctx-bar | 5h | 7d | +/- lines | model | cost.
#
# settings.json:
#   "statusLine": {
#     "type": "command",
#     "command": "pwsh -NoProfile -File C:\\Users\\you\\.claude\\statusline.ps1"
#   }
# Needs pwsh (PowerShell 7+) and git on PATH.

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$raw = [Console]::In.ReadToEnd()
if (-not $raw.Trim()) { exit 0 }
$json = $raw | ConvertFrom-Json

$e = [char]27
function Fg($r, $g, $b)  { "$e[38;2;$r;$g;${b}m" }
function Bfg($r, $g, $b) { "$e[1;38;2;$r;$g;${b}m" }
$RESET   = "$e[0m"
$YELLOW  = Fg 220 200 0
$GREEN   = Fg 0 200 80
$RED     = Fg 220 40 20
$MAGENTA = Fg 200 0 200
$DIM     = Fg 100 100 100
$PIPE    = "$DIM | $RESET"

# --- fields -----------------------------------------------------------------
$model = if ($json.model.display_name) { $json.model.display_name } else { "Claude" }
$used  = [double]($json.context_window.used_percentage)
$cost  = [double]($json.cost.total_cost_usd)
$added   = [int]($json.cost.total_lines_added)
$removed = [int]($json.cost.total_lines_removed)
$cwd = if ($json.workspace.current_dir) { $json.workspace.current_dir }
       elseif ($json.cwd) { $json.cwd } else { $PWD.Path }
$fivePct   = $json.rate_limits.five_hour.used_percentage
$fiveReset = $json.rate_limits.five_hour.resets_at
$weekPct   = $json.rate_limits.seven_day.used_percentage
$weekReset = $json.rate_limits.seven_day.resets_at

# --- repo + branch ----------------------------------------------------------
$repo = ""; $branch = ""
if ($cwd) {
  $top = git -C "$cwd" rev-parse --show-toplevel 2>$null
  $repo = if ($top) { Split-Path $top.Trim() -Leaf } else { Split-Path $cwd -Leaf }
  $b = git -C "$cwd" branch --show-current 2>$null
  if (-not $b) { $b = git -C "$cwd" rev-parse --short HEAD 2>$null }
  if ($b) { $branch = $b.Trim() }
}

# --- per-block green(0,200,80) -> yellow(220,200,0) -> red(220,40,20) bar ----
function Gradient-Bar([double]$pct, [int]$n) {
  $half = [int]($n / 2)
  $filled = [int][math]::Round($pct * $n / 100.0)
  if ($filled -lt 0) { $filled = 0 }
  if ($filled -gt $n) { $filled = $n }
  $bar = ""
  for ($i = 0; $i -lt $n; $i++) {
    if ($i -lt $filled) {
      if ($i -lt $half) {
        $r = [int][math]::Floor(220 * $i / $half); $g = 200; $b = [int][math]::Floor(80 - 80 * $i / $half)
      } else {
        $j = $i - $half; $r = 220; $g = [int][math]::Floor(200 - 160 * $j / $half); $b = [int][math]::Floor(20 * $j / $half)
      }
      $bar += (Fg $r $g $b) + "█"
    } else {
      $bar += (Fg 60 60 60) + "█"
    }
  }
  $bar + $RESET
}

# --- color a percentage by usage band (matches the emoji bands) -------------
function Pct-Color([double]$p) {
  $x = [int][math]::Round($p)
  if     ($x -ge 90) { Fg 220 40 20 }
  elseif ($x -ge 70) { Fg 220 120 20 }
  elseif ($x -ge 20) { Fg 220 200 0 }
  else               { Fg 0 200 80 }
}

# --- "in Xm" / "in Xh Ym" / "in Xd Yh" until a unix timestamp ----------------
function Format-Reset([long]$ts) {
  $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
  $diff = $ts - $now
  if ($diff -le 0) { return "now" }
  $mins = [int]($diff / 60); $hours = [int]($mins / 60); $days = [int]($hours / 24)
  if     ($days -ge 1)  { "in ${days}d $($hours % 24)h" }
  elseif ($hours -ge 1) { "in ${hours}h $($mins % 60)m" }
  else                  { "in ${mins}m" }
}

# --- context emoji ----------------------------------------------------------
$pctInt = [int][math]::Round($used)
if     ($pctInt -ge 90) { $emoji = "🚨" }
elseif ($pctInt -ge 70) { $emoji = "🔥" }
elseif ($pctInt -ge 20) { $emoji = "⚡" }
else                    { $emoji = "🟢" }

# --- assemble ---------------------------------------------------------------
$parts = @()
$parts += (Bfg 220 200 0) + $repo + $RESET
if ($branch) { $parts += (Bfg 0 180 200) + "🌿 ($branch)" + $RESET }
$parts += "$emoji $(Gradient-Bar $used 20) $(Pct-Color $used)$pctInt%$RESET"

if ($null -ne $fivePct -and "$fivePct" -ne "") {
  $fp = [int][math]::Round([double]$fivePct)
  $reset = if ($fiveReset) { " $DIM($(Format-Reset ([long]$fiveReset)))$RESET" } else { "" }
  $parts += "${DIM}5h$RESET $(Gradient-Bar ([double]$fivePct) 10) $(Pct-Color ([double]$fivePct))$fp%$RESET$reset"
}
if ($null -ne $weekPct -and "$weekPct" -ne "") {
  $wp = [int][math]::Round([double]$weekPct)
  $reset = if ($weekReset) { " $DIM($(Format-Reset ([long]$weekReset)))$RESET" } else { "" }
  $parts += "${DIM}7d$RESET $(Gradient-Bar ([double]$weekPct) 10) $(Pct-Color ([double]$weekPct))$wp%$RESET$reset"
}

$parts += "$GREEN+$added$RESET $RED-$removed$RESET"
$parts += "$MAGENTA🤖 $model$RESET"
$parts += "$YELLOW`$$('{0:F2}' -f $cost)$RESET"

[Console]::Write($parts -join $PIPE)
