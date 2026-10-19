#!/usr/bin/env bash
# Shared setup for all bats suites.

setup_repo_root() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  export REPO_ROOT
}

# Give a test an isolated HOME so nothing can touch the real one.
setup_fake_home() {
  FAKE_HOME="$(mktemp -d)"
  export FAKE_HOME
  export HOME="$FAKE_HOME"
}

teardown_fake_home() {
  [[ -n "${FAKE_HOME:-}" && -d "$FAKE_HOME" ]] && rm -rf "$FAKE_HOME"
  return 0
}
