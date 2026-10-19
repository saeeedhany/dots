#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  setup_fake_home
  unset DISPLAY TMUX
  "$REPO_ROOT/theme" white >/dev/null
}

teardown() {
  tmux -L dots-test kill-server 2>/dev/null || true
  teardown_fake_home
}

@test "tmux theme file is flat: status lines use only the theme bg" {
  f="$HOME/.cache/theme/tmux.conf"
  grep -q 'status-style "bg=#e8e6e1' "$f"
  others=$(grep -E 'status|window-status' "$f" | grep -oE 'bg=#[0-9a-f]{6}' | grep -v 'bg=#e8e6e1' || true)
  [ -z "$others" ]
  grep -q $'\|' "$f" && return 1; true
}

@test "tmux.conf has no hardcoded colors and loads the theme file" {
  grep -qE '#[0-9a-fA-F]{6}' "$REPO_ROOT/config/tmux/tmux.conf" && return 1
  grep -qx 'source-file -q ~/.cache/theme/tmux.conf' "$REPO_ROOT/config/tmux/tmux.conf"
}

@test "a tmux server started with the config uses the theme" {
  tmux -L dots-test -f "$REPO_ROOT/config/tmux/tmux.conf" new -d
  run tmux -L dots-test show -g status-style
  [[ "$output" == *"#e8e6e1"* ]]
}

@test "bash prompt takes its colors from the theme" {
  ln -s "$REPO_ROOT/home/bashrc" "$HOME/.bashrc"
  run bash -ic 'printf "%s" "$PS1"' 2>/dev/null
  [[ "$output" == *"38;2;58;54;51"* ]]
}

@test "bash prompt falls back to the Onyx colors without a theme" {
  rm -rf "$HOME/.cache/theme"
  ln -s "$REPO_ROOT/home/bashrc" "$HOME/.bashrc"
  run bash -ic 'printf "%s" "$PS1"' 2>/dev/null
  [[ "$output" == *"38;2;204;195;184"* ]]
}

@test "dunst gets a themed drop-in and dunstrc has no colors" {
  f="$HOME/.config/dunst/dunstrc.d/theme.conf"
  grep -q 'background = "#e8e6e1"' "$f"
  grep -q '\[urgency_critical\]' "$f"
  grep -qE '#[0-9a-fA-F]{6}' "$REPO_ROOT/config/dunst/dunstrc" && return 1; true
}

@test "zathura includes a themed file and zathurarc has no colors" {
  grep -qx 'set default-bg "#e8e6e1"' "$HOME/.config/zathura/theme"
  grep -qx 'include theme' "$REPO_ROOT/config/zathura/zathurarc"
  grep -qE '#[0-9a-fA-F]{6}' "$REPO_ROOT/config/zathura/zathurarc" && return 1; true
}
