#!/usr/bin/env bash
# Colours and logging shared by every script in this repo.
# Sourced, never executed. Callers set DRY_RUN before using run_cmd.

R='\033[0;31m'; G='\033[0;32m'; Y='\033[0;33m'
B='\033[0;34m'; C='\033[0;36m'; D='\033[0;90m'
NC='\033[0m'

log()  { printf "${D}[${NC}${G}+${NC}${D}]${NC} %s\n" "$*"; }
info() { printf "${D}[${NC}${B}*${NC}${D}]${NC} %s\n" "$*"; }
warn() { printf "${D}[${NC}${Y}!${NC}${D}]${NC} %s\n" "$*" >&2; }
ok()   { printf "${D}[${NC}${C}✓${NC}${D}]${NC} %s\n" "$*"; }
die()  { printf "${D}[${NC}${R}✗${NC}${D}]${NC} %s\n" "$*" >&2; exit 1; }

is_dry_run() { [[ "${DRY_RUN:-0}" == "1" ]]; }

# run_cmd <description> <command> [args...]
# Runs the command, or only announces it under DRY_RUN.
run_cmd() {
  local desc="$1"; shift
  if is_dry_run; then
    printf "${D}[${NC}${Y}dry-run${NC}${D}]${NC} %s\n" "$desc"
    return 0
  fi
  "$@"
}
