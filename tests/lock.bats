#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  setup_fake_home
}

teardown() { teardown_fake_home; }

val() { sed -n "s/^$1=//p" "$REPO_ROOT/themes/blue" | tr 'A-F' 'a-f'; }

@test "theme gives slock its colors: the surface, a lift while typing, a quiet red on failure" {
  "$REPO_ROOT/theme" blue >/dev/null
  f="$HOME/.cache/theme/Xresources"
  grep -qx "slock.init: $(val bg)" "$f"
  grep -qx "slock.input: $(val line)" "$f"
  grep -qx "slock.failed: $(val red_dark)" "$f"
}

@test "xinitrc locks with slock on lid close, suspend and after 10 idle minutes" {
  f="$REPO_ROOT/home/xinitrc"
  grep -qx 'xset s 600' "$f"
  grep -qx 'command -v xss-lock >/dev/null && xss-lock -- slock &' "$f"
}

@test "super shift l locks now, through the same xss-lock" {
  grep -A1 -x 'super + shift + l' "$REPO_ROOT/config/sxhkd/sxhkdrc" | tail -1 | grep -qx '    loginctl lock-session'
}

@test "xss-lock is a listed package" {
  grep -qx 'xss-lock' "$REPO_ROOT/packages/pacman.txt"
}
