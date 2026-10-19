#!/usr/bin/env bash
# zathurarc ends with "include theme", resolved next to zathurarc
# shellcheck disable=SC2154 # theme variables are set by theme_load

render_zathura() {
  local dir="$HOME/.config/zathura" a
  a="$(hex_rgb "$accent")"
  mkdir -p "$dir"
  cat > "$dir/theme" <<ZATHURA
set default-bg "$bg"
set default-fg "$fg"
set statusbar-bg "$bg"
set statusbar-fg "$fg1"
set inputbar-bg "$bg"
set inputbar-fg "$fg"
set notification-bg "$bg"
set notification-fg "$fg"
set notification-error-bg "$bg"
set notification-error-fg "$red"
set notification-warning-bg "$bg"
set notification-warning-fg "$accent"
set completion-bg "$bg1"
set completion-fg "$fg"
set completion-group-bg "$bg"
set completion-group-fg "$fg2"
set completion-highlight-bg "$accent"
set completion-highlight-fg "$bg"
set highlight-color "rgba($a, 0.5)"
set highlight-active-color "rgba($a, 0.8)"
set render-loading-bg "$bg"
set render-loading-fg "$fg"
set recolor-lightcolor "$bg"
set recolor-darkcolor "$fg"
ZATHURA
}

reload_zathura() { :; }
