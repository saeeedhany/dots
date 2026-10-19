#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  DRY_RUN=0
  source "$REPO_ROOT/lib/log.sh"
}

@test "ok prints the message" {
  run ok "everything fine"
  [ "$status" -eq 0 ]
  [[ "$output" == *"everything fine"* ]]
}

@test "die prints the message and exits 1" {
  run die "fatal thing"
  [ "$status" -eq 1 ]
  [[ "$output" == *"fatal thing"* ]]
}

@test "run_cmd executes the command when DRY_RUN=0" {
  local marker="$BATS_TEST_TMPDIR/marker"
  DRY_RUN=0
  run_cmd "create marker" touch "$marker"
  [ -f "$marker" ]
}

@test "run_cmd does not execute the command when DRY_RUN=1" {
  local marker="$BATS_TEST_TMPDIR/marker"
  DRY_RUN=1
  run_cmd "create marker" touch "$marker"
  [ ! -f "$marker" ]
}

@test "run_cmd announces the description when DRY_RUN=1" {
  DRY_RUN=1
  run run_cmd "create marker" touch /nonexistent/whatever
  [ "$status" -eq 0 ]
  [[ "$output" == *"dry-run"* ]]
  [[ "$output" == *"create marker"* ]]
}
