#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  setup_fake_home
}

teardown() { teardown_fake_home; }

@test "--dry-run --yes runs every step in order and changes nothing" {
  run "$REPO_ROOT/install.sh" --dry-run --yes
  [ "$status" -eq 0 ]
  order=$(printf '%s\n' "$output" | grep -oE '== [a-z]+' | cut -c4- | paste -sd' ')
  [ "$order" = "check packages aur suckless links wallpapers fonts theme verify" ]
  [ -z "$(ls -A "$HOME")" ]
}

@test "--only links creates links and runs no other step" {
  run "$REPO_ROOT/install.sh" --only links --yes
  [ "$status" -eq 0 ]
  [ -L "$HOME/.bashrc" ]
  [ "$(printf '%s\n' "$output" | grep -oE '== [a-z]+' | cut -c4- | paste -sd' ')" = "links" ]
}

@test "--skip removes steps" {
  run "$REPO_ROOT/install.sh" --dry-run --yes --skip packages,aur
  [ "$status" -eq 0 ]
  [[ "$output" != *"== packages"* ]]
  [[ "$output" != *"== aur"* ]]
  [[ "$output" == *"== links"* ]]
}

@test "an unknown flag exits non-zero with usage" {
  run "$REPO_ROOT/install.sh" --bogus
  [ "$status" -ne 0 ]
  [[ "$output" == *"usage"* ]]
}

@test "an unknown step name is refused" {
  run "$REPO_ROOT/install.sh" --only nope --yes
  [ "$status" -ne 0 ]
}

@test "running as root is refused" {
  FAKE_EUID=0 run "$REPO_ROOT/install.sh" --only check --yes
  [ "$status" -eq 1 ]
  [[ "$output" == *"root"* ]]
}

@test "verify fails in an empty home and names what is missing" {
  run "$REPO_ROOT/install.sh" --only verify --yes
  [ "$status" -eq 1 ]
  [[ "$output" == *".bashrc"* ]]
  [[ "$output" == *".config/theme"* ]]
}

@test "--theme sets the theme the theme step applies" {
  run "$REPO_ROOT/install.sh" --dry-run --yes --only theme --theme black
  [ "$status" -eq 0 ]
  [[ "$output" == *"theme black"* ]]
}

@test "sync.sh reports packages added and removed since the snapshot" {
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  printf '#!/bin/sh\nprintf "base\\nnewpkg\\n"\n' > "$BATS_TEST_TMPDIR/bin/pacman"
  chmod +x "$BATS_TEST_TMPDIR/bin/pacman"
  printf '# header\nbase\noldpkg\n' > "$BATS_TEST_TMPDIR/all.txt"
  PATH="$BATS_TEST_TMPDIR/bin:$PATH" PACKAGES_ALL="$BATS_TEST_TMPDIR/all.txt" run "$REPO_ROOT/sync.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"+ newpkg"* ]]
  [[ "$output" == *"- oldpkg"* ]]
  PATH="$BATS_TEST_TMPDIR/bin:$PATH" PACKAGES_ALL="$BATS_TEST_TMPDIR/all.txt" run "$REPO_ROOT/sync.sh" --apply
  grep -qx newpkg "$BATS_TEST_TMPDIR/all.txt"
  grep -qx oldpkg "$BATS_TEST_TMPDIR/all.txt" && return 1; true
}
