#!/usr/bin/env bash
# Vesktop theme from templates/vesktop.css (onyx.theme.css with placeholders)

render_vesktop() {
  local dir="$HOME/.config/vesktop" settings tmp
  theme_fill "$REPO_ROOT/templates/vesktop.css" "$dir/themes/$THEME.theme.css"
  settings="$dir/settings/settings.json"
  [[ -f "$settings" ]] || return 0
  tmp="$(mktemp)"
  jq --arg t "$THEME.theme.css" '.enabledThemes = [$t]' "$settings" > "$tmp" && mv "$tmp" "$settings"
}

reload_vesktop() {
  pgrep -x vesktop >/dev/null || return 0
  info "vesktop: if the theme didn't switch, press Ctrl+R in Vesktop"
}
