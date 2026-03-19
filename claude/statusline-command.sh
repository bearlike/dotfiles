#!/usr/bin/env bash
# Claude Code status line script (Nerd Font enhanced - nf-md icons)

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
host_part="$(whoami)@$(hostname -s)"
model_name=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_total=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
ctx_used=$(echo "$input" | jq -r '.context_window.tokens_used // 0')
# Try JSON input first, fall back to settings.json
effort=$(echo "$input" | jq -r '.effortLevel // empty')
[ -z "$effort" ] && effort=$(jq -r '.effortLevel // empty' ~/.claude/settings.json 2>/dev/null)

# Shorten cwd: replace $HOME with ~
home_dir="$HOME"
short_dir="${cwd/#$home_dir/\~}"

# ANSI colors
green=$'\033[32m'
red=$'\033[31m'
yellow=$'\033[33m'
cyan=$'\033[36m'
blue=$'\033[34m'
magenta=$'\033[35m'
reset=$'\033[0m'

# Nerd Font icons with colors baked in
icon_stash="${yellow}󰏗${reset}"
icon_gauge="${cyan}󰓅${reset}"
icon_folder="${blue}󰉋${reset}"
icon_branch="${magenta}󰘬${reset}"
icon_clock="${yellow}󰥔${reset}"
icon_load="${green}󰍛${reset}"
icon_user="${cyan}󰀄${reset}"

# Git info
git_part=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  # Use repo toplevel so counts cover the entire repo, not just $cwd subdir
  repo_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
  branch=$(git -C "$repo_root" -c core.hooksPath=/dev/null symbolic-ref --short HEAD 2>/dev/null || git -C "$repo_root" rev-parse --short HEAD 2>/dev/null)

  stash_count=$(git -C "$repo_root" -c core.hooksPath=/dev/null stash list 2>/dev/null | wc -l | tr -d ' ')
  staged=$(git -C "$repo_root" -c core.hooksPath=/dev/null diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
  unstaged=$(git -C "$repo_root" -c core.hooksPath=/dev/null diff --numstat 2>/dev/null | wc -l | tr -d ' ')
  untracked=$(git -C "$repo_root" -c core.hooksPath=/dev/null ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

  stash_part=""
  [ "$stash_count" -gt 0 ] && stash_part=" ${icon_stash} stash:${stash_count}"

  untracked_part=""
  [ "$untracked" -gt 0 ] && untracked_part=" ${yellow}?${untracked}${reset}"

  git_part=" | ${icon_branch} ${branch}${stash_part} ${green}+${staged}${reset} ${red}-${unstaged}${reset}${untracked_part}"
fi

# Format token count as K or M
fmt_tokens() {
  local n=$1
  if [ "$n" -ge 1000000 ] 2>/dev/null; then
    awk "BEGIN {printf \"%.1fM\", $n/1000000}"
  elif [ "$n" -ge 1000 ] 2>/dev/null; then
    awk "BEGIN {printf \"%dK\", $n/1000}"
  else
    echo "${n}"
  fi
}

# Context usage with color coding and token counts
ctx_part=""
if [ -n "$used_pct" ]; then
  pct_int=$(printf "%.0f" "$used_pct" 2>/dev/null || echo "$used_pct")
  if [ "$pct_int" -ge 75 ] 2>/dev/null; then
    pct_color="$red"
  elif [ "$pct_int" -ge 50 ] 2>/dev/null; then
    pct_color="$yellow"
  else
    pct_color="$cyan"
  fi
  # Calculate used tokens from percentage if not provided directly
  if [ "$ctx_used" -eq 0 ] && [ "$ctx_total" -gt 0 ] 2>/dev/null; then
    ctx_used=$(awk "BEGIN {printf \"%d\", $used_pct/100 * $ctx_total}")
  fi
  used_fmt=$(fmt_tokens "$ctx_used")
  total_fmt=$(fmt_tokens "$ctx_total")
  ctx_part=" | ${icon_gauge} ctx ${pct_color}${pct_int}% (${used_fmt} / ${total_fmt})${reset}"
fi

# Load average (1-min)
load_part=$(awk '{print $1}' /proc/loadavg 2>/dev/null || sysctl -n vm.loadavg 2>/dev/null | awk '{print $2}')

# Time
time_part=$(date +%I:%M%p | sed 's/^0//')

# Effort label
effort_part=""
[ -n "$effort" ] && effort_part=" ${yellow}[${effort}]${reset}"

printf "%s %s | %s %s%s | %s%s%s | %s load:%s | %s %s" \
  "$icon_user" \
  "$host_part" \
  "$icon_folder" \
  "$short_dir" \
  "$git_part" \
  "$model_name" \
  "$effort_part" \
  "$ctx_part" \
  "$icon_load" \
  "$load_part" \
  "$icon_clock" \
  "$time_part"
