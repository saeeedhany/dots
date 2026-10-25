#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  setup_fake_home
  FAKE="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$FAKE"
  for c in systemctl loginctl pkill; do
    printf '#!/bin/sh\necho "%s $*" >> "%s/calls"\n' "$c" "$BATS_TEST_TMPDIR" > "$FAKE/$c"
  done
  chmod +x "$FAKE"/*
  export PATH="$FAKE:$PATH"
}

teardown() { teardown_fake_home; }

pick() {
  printf '#!/bin/sh\ncat > "%s/menu"\necho "%s"\n' "$BATS_TEST_TMPDIR" "$1" > "$FAKE/dmenu"
  chmod +x "$FAKE/dmenu"
  "$REPO_ROOT/bin/power"
}

@test "the menu offers lock first, then suspend, logout, reboot, shutdown" {
  pick ""
  [ "$(paste -sd' ' "$BATS_TEST_TMPDIR/menu")" = "lock suspend logout reboot shutdown" ]
}

@test "each choice runs its action" {
  pick lock; pick suspend; pick logout; pick reboot; pick shutdown
  [ "$(cat "$BATS_TEST_TMPDIR/calls")" = "$(printf 'loginctl lock-session\nsystemctl suspend\npkill -x dwm\nsystemctl reboot\nsystemctl poweroff')" ]
}

@test "escaping the menu does nothing" {
  pick ""
  [ ! -e "$BATS_TEST_TMPDIR/calls" ]
}

@test "super shift e opens the power menu" {
  grep -A1 -x 'super + shift + e' "$REPO_ROOT/config/sxhkd/sxhkdrc" | tail -1 | grep -qx '    power'
}
