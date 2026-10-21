#!/usr/bin/env bash

qt_argb() {
  local c out=()
  for c in "$@"; do out+=("#ff${c#\#}"); done
  local IFS=,
  printf '%s' "${out[*]}" | sed 's/,/, /g'
}

render_qt() {
  local v d icons=breeze active disabled
  theme_dark && icons=breeze-dark
  active="$(qt_argb "$fg" "$bg2" "$line2" "$line" "$bg" "$line" "$fg" "$fg" "$fg" "$bg" "$bg" "$bg" \
    "$accent" "$bg" "$blue" "$color5" "$bg1" "$bg" "$bg1" "$fg" "$fg3")"
  disabled="$(qt_argb "$fg3" "$bg2" "$line2" "$line" "$bg" "$line" "$fg3" "$fg3" "$fg3" "$bg" "$bg" "$bg" \
    "$line" "$fg3" "$fg3" "$fg3" "$bg1" "$bg" "$bg1" "$fg3" "$fg3")"
  for v in 5 6; do
    d="$HOME/.config/qt${v}ct"
    mkdir -p "$d/colors"
    printf '[ColorScheme]\nactive_colors=%s\ndisabled_colors=%s\ninactive_colors=%s\n' \
      "$active" "$disabled" "$active" > "$d/colors/dots.conf"
    ini_set "$d/qt${v}ct.conf" Appearance color_scheme_path "$d/colors/dots.conf"
    ini_set "$d/qt${v}ct.conf" Appearance custom_palette true
    ini_set "$d/qt${v}ct.conf" Appearance style Fusion
    ini_set "$d/qt${v}ct.conf" Appearance icon_theme "$icons"
  done
}

reload_qt() {
  [[ "${QT_QPA_PLATFORMTHEME:-}" == qt5ct || "${QT_QPA_PLATFORMTHEME:-}" == qt6ct ]] && return 0
  info "qt: log in again once so Qt apps use qt5ct"
}
