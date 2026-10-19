#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  ONYX="$HOME/.config/vesktop/themes/onyx.theme.css"
  setup_fake_home
  unset DISPLAY
}

teardown() { teardown_fake_home; }

@test "grey reproduces today's onyx.theme.css exactly" {
  [ -f "$ONYX" ] || skip "no onyx.theme.css on this machine"
  "$REPO_ROOT/theme" grey >/dev/null
  diff <(grep -v '@name' "$HOME/.config/vesktop/themes/grey.theme.css" | tr A-F a-f) \
       <(grep -v '@name' "$ONYX" | tr A-F a-f)
}

@test "the template holds no literal colors except black shadows" {
  t="$REPO_ROOT/templates/vesktop.css"
  [ -f "$t" ]
  grep -qE '#[0-9a-fA-F]{6}\b' "$t" && return 1
  others=$(grep -oE 'rgba?\([0-9]+, *[0-9]+, *[0-9]+' "$t" | grep -v 'rgba(0, 0, 0' || true)
  [ -z "$others" ]
}

@test "gruvbox renders gruvbox colors with nothing left unfilled" {
  "$REPO_ROOT/theme" gruvbox >/dev/null
  f="$HOME/.config/vesktop/themes/gruvbox.theme.css"
  grep -q '#1d2021' "$f"
  grep -q '#83a598' "$f"
  grep -q '{{' "$f" && return 1
  grep -q '@name gruvbox' "$f"
}

@test "settings.json points at the new theme and keeps other settings" {
  mkdir -p "$HOME/.config/vesktop/settings"
  printf '{"enabledThemes":["onyx.theme.css"],"other":1}' > "$HOME/.config/vesktop/settings/settings.json"
  "$REPO_ROOT/theme" blue >/dev/null
  [ "$(jq -c .enabledThemes "$HOME/.config/vesktop/settings/settings.json")" = '["blue.theme.css"]' ]
  [ "$(jq .other "$HOME/.config/vesktop/settings/settings.json")" = 1 ]
}

@test "no settings.json is fine" {
  run "$REPO_ROOT/theme" blue
  [ "$status" -eq 0 ]
  [ -f "$HOME/.config/vesktop/themes/blue.theme.css" ]
}

@test "theme_fill fails on an unknown placeholder" {
  source "$REPO_ROOT/lib/log.sh"; source "$REPO_ROOT/lib/theme.sh"
  theme_load grey
  printf 'a {{nope}} b\n' > "$BATS_TEST_TMPDIR/t"
  run theme_fill "$BATS_TEST_TMPDIR/t" "$BATS_TEST_TMPDIR/out"
  [ "$status" -eq 1 ]
}

@test "a command line that merely mentions vesktop is not Vesktop running" {
  source "$REPO_ROOT/lib/log.sh"; source "$REPO_ROOT/lib/targets/vesktop.sh"
  bash -c 'sleep 5 # vesktop/themes' & p=$!
  run reload_vesktop
  kill "$p"
  [[ "$output" != *"Ctrl+R"* ]]
}
