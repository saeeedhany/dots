#!/usr/bin/env bash
# Colors for dwm, st and dmenu, which read them from the X resource database.
# shellcheck disable=SC2154 # theme variables are set by theme_load

# binary_supports <path> <marker>: true if the binary was built with the
# xresources patch. Unpatched dwm dies on SIGHUP and unpatched st on SIGUSR1,
# so never signal a binary that lacks the marker.
binary_supports() { [[ -f "$1" ]] && grep -qa "$2" "$1"; }

render_xresources() {
  local i c
  {
    for c in normbgcolor normbordercolor selbgcolor selbordercolor; do
      printf 'dwm.%s: %s\n' "$c" "$bg"
    done
    printf 'dwm.normfgcolor: %s\n' "$fg1"
    printf 'dwm.selfgcolor: %s\n' "$fg"
    printf 'st.background: %s\n' "$bg"
    printf 'st.foreground: %s\n' "$fg"
    printf 'st.cursorColor: %s\n' "$cursor"
    for i in $(seq 0 15); do
      c="color$i"
      printf 'st.color%d: %s\n' "$i" "${!c}"
    done
    printf 'dmenu.background: %s\n' "$bg"
    printf 'dmenu.foreground: %s\n' "$fg1"
    printf 'dmenu.selbackground: %s\n' "$bg"
    printf 'dmenu.selforeground: %s\n' "$fg"
  } > "$HOME/.cache/theme/Xresources"
}

reload_xresources() {
  [[ -n "${DISPLAY:-}" ]] || return 0
  xrdb -merge "$HOME/.cache/theme/Xresources"
  if binary_supports "$(command -v dwm || true)" normbgcolor; then
    pkill -HUP -x dwm || true
  else
    info "dwm: not built with xresources yet, restart it to recolor"
  fi
  if binary_supports "$(command -v st || true)" cursorColor; then
    pkill -USR1 -x st || true
  else
    info "st: not built with xresources reload yet, new windows only"
  fi
}
