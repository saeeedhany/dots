#!/usr/bin/env bats
# The suite must never reach the live session: tmux, nvim or dunst.

load test_helper

setup() {
  setup_repo_root
  REAL_TMUX_TMPDIR="${TMUX_TMPDIR:-/tmp}"
  REAL_RUNTIME="${XDG_RUNTIME_DIR:-}"
  setup_fake_home
}

teardown() { teardown_fake_home; }

@test "the fake home isolates tmux, nvim sockets and D-Bus" {
  [ "${TMUX_TMPDIR:-}" != "$REAL_TMUX_TMPDIR" ]
  [[ "$TMUX_TMPDIR" == "$FAKE_SESSION"* ]]
  [[ "${XDG_RUNTIME_DIR:-}" == "$FAKE_SESSION"* ]]
  [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]
  [ -z "${TMUX:-}" ]
}

@test "theme in the fake home never reaches a real tmux server" {
  unset DISPLAY
  "$REPO_ROOT/theme" white >/dev/null
  run tmux info
  [ "$status" -ne 0 ]
}
