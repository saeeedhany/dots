#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  setup_fake_home
  unset DISPLAY
}

teardown() { teardown_fake_home; }

@test "theme blue writes state, colors and Xresources" {
  run "$REPO_ROOT/theme" blue
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.config/theme")" = blue ]
  grep -qx 'dwm.normbgcolor: #1b1f27' "$HOME/.cache/theme/Xresources"
  grep -q '^st.color1: #' "$HOME/.cache/theme/Xresources"
  grep -qx 'dmenu.selforeground: #cdd3de' "$HOME/.cache/theme/Xresources"
  grep -qx 'bg=#1b1f27' "$HOME/.cache/theme/colors.sh"
  grep -qx 'THEME=blue' "$HOME/.cache/theme/colors.sh"
}

@test "theme blue makes a single-color 1920x1080 wallpaper" {
  "$REPO_ROOT/theme" blue
  f="$HOME/Pictures/Wallpapers/blue.png"
  [ "$(magick identify -format '%wx%h' "$f")" = "1920x1080" ]
  run magick "$f" -format %c histogram:info:-
  [ "$(printf '%s\n' "$output" | grep -c .)" -eq 1 ]
  [[ "$output" == *"#1B1F27"* ]]
}

@test "a second run reuses the wallpaper" {
  "$REPO_ROOT/theme" blue
  before=$(stat -c %Y "$HOME/Pictures/Wallpapers/blue.png")
  sleep 1
  "$REPO_ROOT/theme" blue
  [ "$(stat -c %Y "$HOME/Pictures/Wallpapers/blue.png")" = "$before" ]
}

@test "an unknown theme writes nothing and keeps the current one" {
  "$REPO_ROOT/theme" grey
  run "$REPO_ROOT/theme" purple
  [ "$status" -eq 1 ]
  [ "$(cat "$HOME/.config/theme")" = grey ]
  [ ! -e "$HOME/Pictures/Wallpapers/purple.png" ]
}

@test "without X it skips the reloads and still succeeds" {
  run "$REPO_ROOT/theme" grey
  [ "$status" -eq 0 ]
  [[ "$output" == *"no X"* ]]
}

@test "no arguments lists the themes and marks the current one" {
  "$REPO_ROOT/theme" white
  run "$REPO_ROOT/theme"
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c .)" -eq 5 ]
  printf '%s\n' "$output" | grep -qx '\* white'
}

@test "theme works when run through a symlink" {
  mkdir -p "$HOME/.local/bin"
  ln -s "$REPO_ROOT/theme" "$HOME/.local/bin/theme"
  run "$HOME/.local/bin/theme" black
  [ "$status" -eq 0 ]
}

@test "binary_supports only accepts binaries carrying the patch marker" {
  source "$REPO_ROOT/lib/log.sh"
  source "$REPO_ROOT/lib/targets/xresources.sh"
  printf 'plain dwm without the patch' > "$BATS_TEST_TMPDIR/dwm"
  printf 'patched normbgcolor inside' > "$BATS_TEST_TMPDIR/dwm2"
  run binary_supports "$BATS_TEST_TMPDIR/dwm" normbgcolor
  [ "$status" -eq 1 ]
  binary_supports "$BATS_TEST_TMPDIR/dwm2" normbgcolor
}

@test "with X, a patched dwm gets SIGHUP and then an X event to act on it" {
  stubs="$BATS_TEST_TMPDIR/stubs"; mkdir -p "$stubs"
  log="$BATS_TEST_TMPDIR/calls"
  for c in xrdb pkill feh xsetroot; do
    printf '#!/bin/sh\necho "%s $*" >> "%s"\n' "$c" "$log" > "$stubs/$c"
  done
  printf '#!/bin/sh\necho "WM_NAME(UTF8_STRING) = \\"bar text\\""\n' > "$stubs/xprop"
  printf 'normbgcolor cursorColor' > "$stubs/dwm"
  cp "$stubs/dwm" "$stubs/st"
  chmod +x "$stubs"/*
  DISPLAY=:42 PATH="$stubs:$PATH" run "$REPO_ROOT/theme" grey
  [ "$status" -eq 0 ]
  hup=$(grep -n 'pkill -HUP -x dwm' "$log" | cut -d: -f1)
  ev=$(grep -n 'xsetroot -name bar text' "$log" | cut -d: -f1)
  [ -n "$hup" ]
  [ -n "$ev" ]
  [ "$hup" -lt "$ev" ]
  grep -q 'pkill -USR1 -x st' "$log"
}
