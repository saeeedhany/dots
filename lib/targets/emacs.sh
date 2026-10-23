#!/usr/bin/env bash
# shellcheck disable=SC2154 # theme variables are set by theme_load

render_emacs() {
  local k
  {
    printf ';;; -*- lexical-binding: t -*-\n(setq dots-palette\n      (quote ((name . "%s")\n' "$THEME"
    for k in "${THEME_KEYS[@]}"; do printf '              (%s . "%s")\n' "$k" "${!k}"; done
    printf '              (add_bg . "%s")\n' "$(mix "$bg" "$green" 15)"
    printf '              (del_bg . "%s")\n' "$(mix "$bg" "$red" 15)"
    printf '              (add_bg2 . "%s")\n' "$(mix "$bg" "$green" 30)"
    printf '              (del_bg2 . "%s"))))\n' "$(mix "$bg" "$red" 30)"
  } > "$HOME/.cache/theme/emacs.el"
}

reload_emacs() {
  local sock
  command -v emacsclient >/dev/null || return 0
  for sock in "${XDG_RUNTIME_DIR:-/run/user/$UID}"/emacs/*; do
    [[ -S "$sock" ]] || continue
    emacsclient -s "$sock" --eval '(dots-theme-reload)' >/dev/null 2>&1 || true
  done
}
