#!/usr/bin/env bash

gtk_import() {
  local css="$1" theme_css="$2" line tmp
  line="@import url(\"file://$theme_css\");"
  mkdir -p "$(dirname "$css")"
  grep -qxF "$line" "$css" 2>/dev/null && return 0
  tmp="$(mktemp)"
  { printf '%s\n' "$line"; cat "$css" 2>/dev/null || true; } > "$tmp"
  mv "$tmp" "$css"
}

render_gtk() {
  local v dark=0
  theme_dark && dark=1
  for v in 3 4; do
    theme_fill "$REPO_ROOT/templates/gtk$v.css" "$HOME/.cache/theme/gtk$v.css" || return 1
    gtk_import "$HOME/.config/gtk-$v.0/gtk.css" "$HOME/.cache/theme/gtk$v.css"
    ini_set "$HOME/.config/gtk-$v.0/settings.ini" Settings gtk-application-prefer-dark-theme "$dark"
  done
  ini_set "$HOME/.config/gtk-3.0/settings.ini" Settings gtk-theme-name Adwaita
}

reload_gtk() {
  if [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]] && command -v gsettings >/dev/null; then
    local scheme=prefer-light
    theme_dark && scheme=prefer-dark
    gsettings set org.gnome.desktop.interface color-scheme "$scheme" 2>/dev/null || true
  fi
}
