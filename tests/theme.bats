#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  source "$REPO_ROOT/lib/log.sh"
  source "$REPO_ROOT/lib/theme.sh"
}

@test "theme_names lists the five themes" {
  run theme_names
  [ "$(printf '%s' "$output" | paste -sd' ')" = "black blue grey gruvbox white" ]
}

@test "THEME_KEYS has 39 keys" {
  [ "${#THEME_KEYS[@]}" -eq 39 ]
}

@test "theme_load grey sets the Onyx values" {
  theme_load grey
  [ "$THEME" = grey ]
  [ "$bg" = "#282828" ]
  [ "$accent" = "#c8a46b" ]
  [ "$color15" = "#e0d8cd" ]
}

@test "theme_load refuses an unknown theme" {
  run theme_load purple
  [ "$status" -eq 1 ]
}

@test "theme_load refuses a file missing a key, naming it" {
  grep -v '^fg=' "$REPO_ROOT/themes/grey" > "$BATS_TEST_TMPDIR/broken"
  run theme_load_file "$BATS_TEST_TMPDIR/broken"
  [ "$status" -eq 1 ]
  [[ "$output" == *"fg"* ]]
}

@test "theme_load refuses a bad hex value" {
  sed 's/^bg=.*/bg=#28282/' "$REPO_ROOT/themes/grey" > "$BATS_TEST_TMPDIR/broken"
  run theme_load_file "$BATS_TEST_TMPDIR/broken"
  [ "$status" -eq 1 ]
  [[ "$output" == *"bg"* ]]
}

@test "theme_load never runs code from a theme file" {
  { cat "$REPO_ROOT/themes/grey"; echo 'touch "$BATS_TEST_TMPDIR/pwned"'; } > "$BATS_TEST_TMPDIR/evil"
  theme_load_file "$BATS_TEST_TMPDIR/evil" || true
  [ ! -e "$BATS_TEST_TMPDIR/pwned" ]
}

@test "hex_rgb converts to a CSS triplet" {
  [ "$(hex_rgb '#c8a46b')" = "200, 164, 107" ]
}

@test "contrast of white on black is 21" {
  [ "$(contrast '#ffffff' '#000000')" = "21.00" ]
  [ "$(contrast '#000000' '#ffffff')" = "21.00" ]
}

@test "theme_check rejects a low-contrast palette" {
  sed 's/^color1=.*/color1=#3a2a2a/' "$REPO_ROOT/themes/grey" > "$BATS_TEST_TMPDIR/dim"
  run theme_check "$BATS_TEST_TMPDIR/dim"
  [ "$status" -eq 1 ]
  [[ "$output" == *"color1"* ]]
}

@test "theme_check rejects light brights that are lighter than the normals" {
  sed 's/^color9=.*/color9=#c06060/' "$REPO_ROOT/themes/white" > "$BATS_TEST_TMPDIR/w"
  run theme_check "$BATS_TEST_TMPDIR/w"
  [ "$status" -eq 1 ]
}

@test "every theme passes theme_check" {
  for n in black blue grey gruvbox white; do
    run theme_check "$REPO_ROOT/themes/$n"
    [ "$status" -eq 0 ] || { echo "$n: $output"; return 1; }
  done
}
