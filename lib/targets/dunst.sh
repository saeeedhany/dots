#!/usr/bin/env bash
# dunst loads ~/.config/dunst/dunstrc.d/*.conf after dunstrc
# shellcheck disable=SC2154 # theme variables are set by theme_load

render_dunst() {
  local dir="$HOME/.config/dunst/dunstrc.d"
  mkdir -p "$dir"
  cat > "$dir/theme.conf" <<DUNST
[global]
    highlight = "$accent"
    separator_color = "$line"

[urgency_low]
    background = "$bg"
    foreground = "$fg1"
    frame_color = "$line2"

[urgency_normal]
    background = "$bg"
    foreground = "$fg"
    frame_color = "$line2"

[urgency_critical]
    background = "$bg"
    foreground = "$red"
    frame_color = "$red"
DUNST
}

reload_dunst() {
  pgrep -x dunst >/dev/null || return 0
  # dunstctl talks over D-Bus; without a session bus (tty, ssh) dunst picks
  # the drop-in up on its next start
  [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]] || return 0
  dunstctl reload
}
