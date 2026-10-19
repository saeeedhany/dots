#!/usr/bin/env bash
# Colors for dwm, st and dmenu, which read them from the X resource database.
# shellcheck disable=SC2154 # theme variables are set by theme_load

# binary_supports <path> <marker>: true if the binary was built with the
# xresources patch.
binary_supports() { [[ -f "$1" ]] && grep -qa "$2" "$1"; }

# signal_patched <name> <marker> <signal>: signal each running <name> whose
# own binary carries the patch marker. Checks /proc/<pid>/exe, not the file
# on disk: after a reinstall the running process is still the old build, and
# an unpatched dwm dies on SIGHUP (ending the X session), st on SIGUSR1.
# Prints the pids it signalled.
signal_patched() {
  local name="$1" marker="$2" sig="$3" pid
  for pid in $(pgrep -x "$name"); do
    if grep -qa "$marker" "/proc/$pid/exe" 2>/dev/null; then
      kill "-$sig" "$pid" && printf '%s\n' "$pid"
    else
      info "$name ($pid): built before the xresources patch, log out and back in to recolor it" >&2
    fi
  done
}

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
  [[ "${THEME_X:-0}" == 1 ]] || return 0
  xrdb -merge "$HOME/.cache/theme/Xresources"
  if [[ -n "$(signal_patched dwm normbgcolor HUP)" ]]; then
    # dwm acts on SIGHUP at its next X event: re-set the bar text to send one
    xsetroot -name "$(xprop -root WM_NAME 2>/dev/null | sed -n 's/^WM_NAME([A-Z0-9_]*) = "\(.*\)"$/\1/p')"
  fi
  signal_patched st cursorColor USR1 >/dev/null
}
