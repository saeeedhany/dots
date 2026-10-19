#!/usr/bin/env bash
# Flat wallpaper in the theme's bg, kept in ~/Pictures/Wallpapers/<theme>.png
# shellcheck disable=SC2154 # theme variables are set by theme_load

wallpaper_path() { printf '%s/Pictures/Wallpapers/%s.png' "$HOME" "$THEME"; }

render_wallpaper() {
  local out have
  out="$(wallpaper_path)"
  if [[ -f "$out" ]]; then
    have="#$(magick "$out" -format '%[hex:p{0,0}]' info: 2>/dev/null | tr 'A-F' 'a-f' | cut -c1-6)"
    [[ "$have" == "$bg" ]] && return 0
  fi
  mkdir -p "$(dirname "$out")"
  magick -size 1920x1080 "xc:$bg" "PNG24:$out"
}

reload_wallpaper() {
  [[ "${THEME_X:-0}" == 1 ]] || return 0
  feh --bg-fill "$(wallpaper_path)"
}
