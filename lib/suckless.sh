#!/usr/bin/env bash

suckless_dir() {
  local d="${SUCKLESS_DIR:-$(dirname "$REPO_ROOT")/suckless}"
  [[ -d "$d" ]] && printf '%s' "$d"
}

dwm_restartable() { grep -qa _NET_CLIENT_INFO "$1" 2>/dev/null; }
