#!/bin/bash

# Colors only when writing to a terminal.
if [ -t 1 ]; then
  bold=$'\033[1m'; cyan=$'\033[36m'; yellow=$'\033[33m'; reset=$'\033[0m'
else
  bold=""; cyan=""; yellow=""; reset=""
fi

# step <title>: heading for the next stage.
step() {
  echo ""
  echo "${bold}$1${reset}"
}

rule="────────────────────────────────────────────────"

# run <command...>: shows the command in a framed line, then runs it.
run() {
  local shown="" arg
  for arg in "$@"; do
    case "$arg" in
      *[[:space:]]*) shown+=" \"$arg\"" ;;
      *) shown+=" $arg" ;;
    esac
  done
  echo ""
  echo "${cyan}${rule}${reset}"
  echo "  Running command:${cyan}${shown}${reset}"
  echo "${cyan}${rule}${reset}"
  echo ""
  "$@"
}

step "Status"
run git status

echo "-----------------------------------------------------------------------------------"
read -p "${yellow}Press enter to git add and git commit with the supplied message or ctrl-c to cancel${reset}"

step "Adding changes"

# Stage untracked files first
run git add -N .

# Then continue interactively
run git add -p

commitMessage="'$1'"

step "Creating commit - ($commitMessage)"

run git commit --allow-empty -m "$commitMessage"

echo "---------------------------------------"
read -p "${yellow}Press enter to push or ctrl-c to cancel${reset}"

step "Pushing"
run git push
