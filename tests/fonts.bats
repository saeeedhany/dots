#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  setup_fake_home
  export XDG_CONFIG_HOME="$HOME/.config" XDG_CACHE_HOME="$HOME/.cache"
  mkdir -p "$HOME/.config"
  ln -s "$REPO_ROOT/config/fontconfig" "$HOME/.config/fontconfig"
}

teardown() { teardown_fake_home; }

@test "arabic text gets noto sans arabic from the linked fonts config" {
  [ "$(fc-match ':lang=ar' family)" = "Noto Sans Arabic" ]
}

@test "the fonts config is linked like every other config" {
  source "$REPO_ROOT/lib/log.sh"
  source "$REPO_ROOT/lib/link.sh"
  link_map | grep -qF "config/fontconfig"$'\t'"$HOME/.config/fontconfig"
}
