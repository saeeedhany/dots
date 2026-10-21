#!/usr/bin/env bash

kde_rgb() { hex_rgb "$1" | tr -d ' '; }

kde_colors() {
  local name="$1" bg_normal="$2" bg_alt="$3" fg_normal="$4" fg_inactive="$5"
  cat <<KDE
[Colors:$name]
BackgroundNormal=$(kde_rgb "$bg_normal")
BackgroundAlternate=$(kde_rgb "$bg_alt")
ForegroundNormal=$(kde_rgb "$fg_normal")
ForegroundInactive=$(kde_rgb "$fg_inactive")
ForegroundActive=$(kde_rgb "$accent")
ForegroundLink=$(kde_rgb "$blue")
ForegroundVisited=$(kde_rgb "$color5")
ForegroundNegative=$(kde_rgb "$red")
ForegroundNeutral=$(kde_rgb "$color3")
ForegroundPositive=$(kde_rgb "$green")
DecorationFocus=$(kde_rgb "$accent")
DecorationHover=$(kde_rgb "$line2")

KDE
}

render_kdenlive() {
  local rc="$HOME/.config/kdenliverc" dir="$HOME/.local/share/color-schemes"
  [[ -f "$rc" ]] || return 0
  mkdir -p "$dir"
  {
    kde_colors Window "$bg" "$bg1" "$fg" "$fg2"
    kde_colors View "$bg" "$bg1" "$fg" "$fg2"
    kde_colors Button "$bg2" "$bg3" "$fg" "$fg2"
    kde_colors Selection "$line2" "$line" "$fg" "$fg1"
    kde_colors Tooltip "$bg1" "$bg1" "$fg" "$fg2"
    kde_colors Header "$bg" "$bg1" "$fg" "$fg2"
    kde_colors Complementary "$bg" "$bg1" "$fg" "$fg2"
    cat <<KDE
[General]
ColorScheme=dots
Name=dots
shadeSortColumn=false

[KDE]
contrast=0

[WM]
activeBackground=$(kde_rgb "$bg")
activeBlend=$(kde_rgb "$bg")
activeForeground=$(kde_rgb "$fg")
inactiveBackground=$(kde_rgb "$bg")
inactiveBlend=$(kde_rgb "$bg")
inactiveForeground=$(kde_rgb "$fg2")
KDE
  } > "$dir/dots.colors"
  ini_set "$rc" UiSettings ColorScheme dots
  ini_set "$rc" UiSettings ColorSchemePath dots.colors
}

reload_kdenlive() {
  pgrep -x kdenlive >/dev/null || return 0
  info "kdenlive: restart it to see the new theme"
}
