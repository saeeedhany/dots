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

@test "sync.sh keeps native and AUR snapshots apart" {
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  cat > "$BATS_TEST_TMPDIR/bin/pacman" <<'STUB'
#!/bin/sh
case "$1" in
  -Qqen) printf 'base\nnewpkg\n' ;;
  -Qqem) printf 'cursor-bin\n' ;;
esac
STUB
  chmod +x "$BATS_TEST_TMPDIR/bin/pacman"
  printf '# header\nbase\noldpkg\n' > "$BATS_TEST_TMPDIR/all-native.txt"
  printf '# header\n' > "$BATS_TEST_TMPDIR/all-aur.txt"
  export PACKAGES_DIR="$BATS_TEST_TMPDIR"
  PATH="$BATS_TEST_TMPDIR/bin:$PATH" run "$REPO_ROOT/sync.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"+ newpkg"* ]]
  [[ "$output" == *"- oldpkg"* ]]
  [[ "$output" == *"+ cursor-bin"* ]]
  PATH="$BATS_TEST_TMPDIR/bin:$PATH" run "$REPO_ROOT/sync.sh" --apply
  grep -qx newpkg "$BATS_TEST_TMPDIR/all-native.txt"
  grep -qx cursor-bin "$BATS_TEST_TMPDIR/all-aur.txt"
  grep -qx cursor-bin "$BATS_TEST_TMPDIR/all-native.txt" && return 1
  grep -qx oldpkg "$BATS_TEST_TMPDIR/all-native.txt" && return 1; true
}

@test "--all sends native packages to pacman and AUR ones to yay" {
  run "$REPO_ROOT/install.sh" --dry-run --yes --all --only packages,aur
  [ "$status" -eq 0 ]
  pac=$(printf '%s\n' "$output" | grep 'pacman -S')
  yay=$(printf '%s\n' "$output" | grep 'yay -S')
  aur1=$(grep -v '^#' "$REPO_ROOT/packages/all-aur.txt" | grep . | head -1)
  [ -n "$aur1" ]
  [[ "$yay" == *"$aur1"* ]]
  [[ "$pac" != *" $aur1 "* ]]
}

@test "install puts ~/.local/bin on PATH for its own steps" {
  PATH="/usr/local/bin:/usr/bin:/bin" run "$REPO_ROOT/install.sh" --only links,verify --yes
  [[ "$output" != *"not on PATH: theme"* ]]
}

@test "sync.sh --apply works when no snapshot exists yet" {
  mkdir -p "$BATS_TEST_TMPDIR/bin" "$BATS_TEST_TMPDIR/empty"
  printf '#!/bin/sh\necho base\n' > "$BATS_TEST_TMPDIR/bin/pacman"
  chmod +x "$BATS_TEST_TMPDIR/bin/pacman"
  PACKAGES_DIR="$BATS_TEST_TMPDIR/empty" PATH="$BATS_TEST_TMPDIR/bin:$PATH" run "$REPO_ROOT/sync.sh" --apply
  [ "$status" -eq 0 ]
  grep -qx base "$BATS_TEST_TMPDIR/empty/all-native.txt"
}

@test "suckless builds and installs without root" {
  body=$(awk '/^step_suckless\(\)/,/^}/' "$REPO_ROOT/install.sh")
  [[ "$body" == *'make -C "$SUCKLESS_DIR" install'* ]]
  [[ "$body" != *sudo* ]]
}
