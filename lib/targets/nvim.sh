#!/usr/bin/env bash
# nvim reads ~/.cache/theme/nvim.lua (lua/core/apply_theme.lua)

render_nvim() {
  local k
  {
    printf 'return {\n  name = "%s",\n' "$THEME"
    for k in "${THEME_KEYS[@]}"; do printf '  %s = "%s",\n' "$k" "${!k}"; done
    printf '}\n'
  } > "$HOME/.cache/theme/nvim.lua"
}

# Recolor running instances through their server sockets.
reload_nvim() {
  local sock
  for sock in "${XDG_RUNTIME_DIR:-/run/user/$UID}"/nvim.*.0; do
    [[ -S "$sock" ]] || continue
    nvim --server "$sock" --remote-send '<C-\><C-n>:lua require("core.apply_theme")()<CR>' >/dev/null 2>&1 || true
  done
}
