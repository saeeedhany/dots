#!/usr/bin/env bash
# Shared setup for all bats suites.

setup_repo_root() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  export REPO_ROOT
}

# Give a test an isolated HOME and session: its own tmux socket dir and
# runtime dir (nvim sockets), and no D-Bus, so theme reloads can never reach
# the live tmux, nvim or dunst.
setup_fake_home() {
  FAKE_HOME="$(mktemp -d)"
  export FAKE_HOME
  export HOME="$FAKE_HOME"
  FAKE_SESSION="$(mktemp -d)"
  export FAKE_SESSION
  export TMUX_TMPDIR="$FAKE_SESSION/tmux"
  export XDG_RUNTIME_DIR="$FAKE_SESSION/run"
  mkdir -p "$TMUX_TMPDIR" "$XDG_RUNTIME_DIR"
  chmod 700 "$XDG_RUNTIME_DIR"
  unset DBUS_SESSION_BUS_ADDRESS TMUX
  # no X either: a test that wants X sets DISPLAY for one command, with
  # pgrep stubbed, so the live dwm and st can never be signalled
  unset DISPLAY
}

teardown_fake_home() {
  [[ -n "${FAKE_HOME:-}" && -d "$FAKE_HOME" ]] && rm -rf "$FAKE_HOME"
  [[ -n "${FAKE_SESSION:-}" && -d "$FAKE_SESSION" ]] && rm -rf "$FAKE_SESSION"
  return 0
}
