#!/usr/bin/env bats
# nvim runs against the repo config in a fake HOME. Plugins come from the
# real lazy directory (read-only use), so no network is needed.

load test_helper

setup() {
  setup_repo_root
  REAL_LAZY="$HOME/.local/share/nvim/lazy"
  setup_fake_home
  unset DISPLAY TMUX
  mkdir -p "$HOME/.config" "$HOME/.local/share/nvim"
  ln -s "$REPO_ROOT/config/nvim" "$HOME/.config/nvim"
  ln -s "$REAL_LAZY" "$HOME/.local/share/nvim/lazy"
}

teardown() { teardown_fake_home; }

nv() { nvim --headless -c "lua io.write($1)" -c 'qa!' 2>/dev/null; }

@test "theme blue: nvim uses the generated scheme" {
  "$REPO_ROOT/theme" blue >/dev/null
  [ "$(nv 'vim.g.colors_name')" = "theme" ]
}

@test "theme blue: CursorLineNr is blue's accent" {
  "$REPO_ROOT/theme" blue >/dev/null
  accent=$(sed -n 's/^accent=//p' "$REPO_ROOT/themes/blue")
  [ "$(nv 'string.format("#%06x", vim.api.nvim_get_hl(0, {name = "CursorLineNr"}).fg)')" = "$accent" ]
}

@test "theme blue: Normal is transparent" {
  "$REPO_ROOT/theme" blue >/dev/null
  [ "$(nv 'tostring(vim.api.nvim_get_hl(0, {name = "Normal"}).bg)')" = "nil" ]
}

@test "theme gruvbox: nvim uses gruvbox.nvim" {
  "$REPO_ROOT/theme" gruvbox >/dev/null
  [ "$(nv 'vim.g.colors_name')" = "gruvbox" ]
}

@test "no theme applied yet: nvim falls back to gruvbox" {
  [ "$(nv 'vim.g.colors_name')" = "gruvbox" ]
}
