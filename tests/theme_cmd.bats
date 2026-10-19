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

# Fake dwm/st processes for the signal tests. pgrep is stubbed to report only
# these, so the real session's dwm and st can never be signalled.
fake_session() {
  stubs="$BATS_TEST_TMPDIR/stubs"; mkdir -p "$stubs"
  log="$BATS_TEST_TMPDIR/calls"; : > "$log"
  # pkill is stubbed to only log: signals must go to checked pids, never by name
  for c in xrdb feh xsetroot pkill; do
    printf '#!/bin/sh\necho "%s $*" >> "%s"\n' "$c" "$log" > "$stubs/$c"
  done
  printf '#!/bin/sh\necho "WM_NAME(UTF8_STRING) = \\"bar text\\""\n' > "$stubs/xprop"
  # what is installed on disk: always the patched builds
  printf 'normbgcolor cursorColor' > "$stubs/dwm"; cp "$stubs/dwm" "$stubs/st"
  # what is running: $1 = patched|unpatched
  if [ "$1" = patched ]; then
    { cat "$(command -v sleep)"; printf 'normbgcolor cursorColor'; } > "$BATS_TEST_TMPDIR/run-bin"
  else
    cp "$(command -v sleep)" "$BATS_TEST_TMPDIR/run-bin"
  fi
  chmod +x "$BATS_TEST_TMPDIR/run-bin"
  "$BATS_TEST_TMPDIR/run-bin" 60 & DWM_PID=$!
  "$BATS_TEST_TMPDIR/run-bin" 60 & ST_PID=$!
  printf '#!/bin/sh\ncase "$*" in *dwm*) echo %s ;; *-x\ st*) echo %s ;; *) exit 1 ;; esac\n' "$DWM_PID" "$ST_PID" > "$stubs/pgrep"
  chmod +x "$stubs"/*
}

@test "with X, a running patched dwm gets SIGHUP then an X event; st gets USR1" {
  fake_session patched
  DISPLAY=:42 PATH="$stubs:$PATH" run "$REPO_ROOT/theme" grey
  [ "$status" -eq 0 ]
  sleep 0.3
  ! kill -0 "$DWM_PID" 2>/dev/null
  ! kill -0 "$ST_PID" 2>/dev/null
  grep -q 'xsetroot -name bar text' "$log"
  grep -q '^pkill' "$log" && return 1; true
}

@test "a running dwm/st built before the patch is never signalled, even if disk has the new build" {
  fake_session unpatched
  DISPLAY=:42 PATH="$stubs:$PATH" run "$REPO_ROOT/theme" grey
  [ "$status" -eq 0 ]
  sleep 0.3
  kill -0 "$DWM_PID"
  kill -0 "$ST_PID"
  kill "$DWM_PID" "$ST_PID"
  [[ "$output" == *"log out and back in"* ]]
}

@test "dunst running without D-Bus (tty, ssh): theme still succeeds and is recorded" {
  cp "$(command -v sleep)" "$BATS_TEST_TMPDIR/dunst"
  "$BATS_TEST_TMPDIR/dunst" 30 & fake=$!
  run "$REPO_ROOT/theme" blue
  kill "$fake"
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.config/theme")" = blue ]
}

@test "a DISPLAY with no X server behind it counts as no X" {
  DISPLAY=:77 run "$REPO_ROOT/theme" blue
  [ "$status" -eq 0 ]
  [[ "$output" == *"no X"* ]]
  [ "$(cat "$HOME/.config/theme")" = blue ]
}

@test "a broken vesktop settings.json is reported, not fatal" {
  mkdir -p "$HOME/.config/vesktop/settings"
  echo '{ not json' > "$HOME/.config/vesktop/settings/settings.json"
  run "$REPO_ROOT/theme" blue
  [ "$status" -eq 0 ]
  [[ "$output" == *"settings.json"* ]]
  [ "$(cat "$HOME/.config/theme")" = blue ]
}
