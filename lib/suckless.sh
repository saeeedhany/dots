#!/usr/bin/env bash

suckless_dir() {
  local d
  if [[ -n "${SUCKLESS_DIR:-}" ]]; then
    [[ -d "$SUCKLESS_DIR" ]] && printf '%s' "$SUCKLESS_DIR"
    return
  fi
  for d in "$HOME/gits/suckless" "$HOME/.config/suckless"; do
    [[ -d "$d" ]] && { printf '%s' "$d"; return 0; }
  done
  return 1
}
