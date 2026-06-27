#!/bin/bash
input=$(cat)

# --- pull fields from stdin JSON --------------------------------------------
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
cur_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
cost=$(echo "$input"     | jq -r '.cost.total_cost_usd // 0')
added=$(echo "$input"    | jq -r '.cost.total_lines_added // 0')
removed=$(echo "$input"  | jq -r '.cost.total_lines_removed // 0')
dur_ms=$(echo "$input"   | jq -r '.cost.total_duration_ms // 0')
five_pct=$(echo "$input"    | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_pct=$(echo "$input"    | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_resets=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

[ -z "$cur_dir" ] && cur_dir="$PWD"

# --- repo + branch ----------------------------------------------------------
repo=$(basename "$(git -C "$cur_dir" rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null)
[ -z "$repo" ] && repo=$(basename "$cur_dir")
branch=$(git -C "$cur_dir" branch --show-current 2>/dev/null)
[ -z "$branch" ] && branch=$(git -C "$cur_dir" rev-parse --short HEAD 2>/dev/null)

# --- ANSI / truecolor helpers -----------------------------------------------
ESC=$(printf '\033')
RESET="${ESC}[0m"
fg()  { printf '%s[38;2;%d;%d;%dm' "$ESC" "$1" "$2" "$3"; }
bfg() { printf '%s[1;38;2;%d;%d;%dm' "$ESC" "$1" "$2" "$3"; }

YELLOW=$(fg 220 200 0)
GREEN=$(fg 0 200 80)
RED=$(fg 220 40 20)
MAGENTA=$(fg 200 0 200)
CYAN=$(fg 0 180 200)
DIM=$(fg 100 100 100)
PIPE="${DIM} | ${RESET}"

# Per-block green(0,200,80) -> yellow(220,200,0) -> red(220,40,20) gradient bar.
gradient_bar() {
  local pct=$1 n=$2 half=$(( $2 / 2 ))
  local filled i r g b
  filled=$(awk -v p="$pct" -v n="$n" 'BEGIN{f=int(p*n/100+0.5);if(f<0)f=0;if(f>n)f=n;print f}')
  local out="" i=0
  while [ "$i" -lt "$n" ]; do
    if [ "$i" -lt "$filled" ]; then
      if [ "$i" -lt "$half" ]; then
        r=$(( 220 * i / half )); g=200; b=$(( 80 - 80 * i / half ))
      else
        local j=$(( i - half )); r=220; g=$(( 200 - 160 * j / half )); b=$(( 20 * j / half ))
      fi
      out="${out}$(fg "$r" "$g" "$b")█"
    else
      out="${out}$(fg 60 60 60)█"
    fi
    i=$(( i + 1 ))
  done
  printf '%s%s' "$out" "$RESET"
}

# Color a percentage by usage band (matches the emoji bands).
pct_color() {
  local p; p=$(awk -v x="$1" 'BEGIN{printf "%d", x+0.5}')
  if   [ "$p" -ge 90 ]; then fg 220 40 20
  elif [ "$p" -ge 70 ]; then fg 220 120 20
  elif [ "$p" -ge 20 ]; then fg 220 200 0
  else                       fg 0 200 80
  fi
}

# Human-readable "in Xm" / "in Xh Ym" / "in Xd Yh" until a unix timestamp.
format_reset() {
  local now diff mins hours days
  now=$(date +%s); diff=$(( $1 - now ))
  [ "$diff" -le 0 ] && { echo "now"; return; }
  mins=$(( diff / 60 )); hours=$(( mins / 60 )); days=$(( hours / 24 ))
  if   [ "$days" -ge 1 ];  then echo "in ${days}d $(( hours % 24 ))h"
  elif [ "$hours" -ge 1 ]; then echo "in ${hours}h $(( mins % 60 ))m"
  else echo "in ${mins}m"
  fi
}

# --- context emoji ----------------------------------------------------------
pct_int=$(awk -v p="$used_pct" 'BEGIN{printf "%d", p+0.5}')
if   [ "$pct_int" -ge 90 ]; then emoji="🚨"
elif [ "$pct_int" -ge 70 ]; then emoji="🔥"
elif [ "$pct_int" -ge 20 ]; then emoji="⚡"
else                             emoji="🟢"
fi

# --- code velocity (lines changed per minute of session) --------------------
velocity=$(awk -v a="$added" -v r="$removed" -v d="$dur_ms" \
  'BEGIN{ if(d>0){ printf "%d", (a+r)/(d/60000)+0.5 } else { print 0 } }')

# --- assemble ---------------------------------------------------------------
out="$(bfg 220 200 0)${repo}${RESET}"
[ -n "$branch" ] && out="${out}${PIPE}$(bfg 0 180 200)🌿 (${branch})${RESET}"

out="${out}${PIPE}${emoji} $(gradient_bar "$used_pct" 20) $(pct_color "$used_pct")${pct_int}%${RESET}"

if [ -n "$five_pct" ]; then
  fp=$(awk -v p="$five_pct" 'BEGIN{printf "%d", p+0.5}')
  reset=""; [ -n "$five_resets" ] && reset=" ${DIM}($(format_reset "$five_resets"))${RESET}"
  out="${out}${PIPE}${DIM}5h${RESET} $(gradient_bar "$five_pct" 10) $(pct_color "$five_pct")${fp}%${RESET}${reset}"
fi
if [ -n "$week_pct" ]; then
  wp=$(awk -v p="$week_pct" 'BEGIN{printf "%d", p+0.5}')
  reset=""; [ -n "$week_resets" ] && reset=" ${DIM}($(format_reset "$week_resets"))${RESET}"
  out="${out}${PIPE}${DIM}7d${RESET} $(gradient_bar "$week_pct" 10) $(pct_color "$week_pct")${wp}%${RESET}${reset}"
fi

[ "$velocity" -gt 0 ] 2>/dev/null && out="${out}${PIPE}${CYAN}⚡${velocity} ln/m${RESET}"
out="${out}${PIPE}${GREEN}+${added}${RESET} ${RED}-${removed}${RESET}"
out="${out}${PIPE}${MAGENTA}🤖 ${model}${RESET}"
out="${out}${PIPE}${YELLOW}\$$(printf '%.2f' "$cost")${RESET}"

printf "%s" "$out"
