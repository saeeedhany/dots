#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  DRY_RUN=0
  source "$REPO_ROOT/lib/log.sh"
  source "$REPO_ROOT/lib/pkg.sh"
}

@test "pkg_list strips comments and blank lines" {
  printf '# header\n\nfoo   # trailing\n  bar\n\n' > "$BATS_TEST_TMPDIR/list"
  run pkg_list "$BATS_TEST_TMPDIR/list"
  [ "$status" -eq 0 ]
  [ "$output" = $'foo\nbar' ]
}

@test "every curated native package exists in the repos" {
  while read -r p; do
    pacman -Si "$p" >/dev/null 2>&1 || { echo "not in repos: $p"; return 1; }
  done < <(pkg_list "$REPO_ROOT/packages/pacman.txt")
}

@test "every binary the configs call is on PATH" {
  for b in picom dunst sxhkd feh scrot xdotool xclip xcolor brightnessctl pamixer \
           notify-send acpi sensors tmux nvim fzf bat rg fd tree nnn zathura \
           setxkbmap xrandr xsetroot xkill jq magick xrdb xprop dunstctl; do
    command -v "$b" >/dev/null || { echo "not on PATH: $b"; return 1; }
  done
}

@test "DRY_RUN installs nothing and names the packages" {
  printf 'foo\nbar\n' > "$BATS_TEST_TMPDIR/list"
  DRY_RUN=1 run pkg_install_native "$BATS_TEST_TMPDIR/list"
  [ "$status" -eq 0 ]
  [[ "$output" == *"foo bar"* ]]
}
