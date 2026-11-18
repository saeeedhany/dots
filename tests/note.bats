#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  setup_fake_home
}

teardown() { teardown_fake_home; }

val() { sed -n "s/^$1=//p" "$REPO_ROOT/themes/blue" | tr 'A-F' 'a-f'; }

@test "theme gives notes their colors: a lifted surface, the text, the accent cursor" {
  "$REPO_ROOT/theme" blue >/dev/null
  f="$HOME/.cache/theme/Xresources"
  grep -qx "note.background: $(val bg3)" "$f"
  grep -qx "note.foreground: $(val fg)" "$f"
  grep -qx "note.cursor: $(val cursor)" "$f"
}

@test "theme recolors open notes the way it recolors st" {
  grep -qx '  signal_patched note note.background USR1 >/dev/null' "$REPO_ROOT/lib/targets/xresources.sh"
}

@test "xinitrc brings notes back at login" {
  grep -qx 'command -v note >/dev/null && note -r &' "$REPO_ROOT/home/xinitrc"
}

@test "the old nvim note script is gone" {
  [ ! -e "$REPO_ROOT/bin/note" ]
}

@test "theme gives notes four tints of its own colors, matching the compiled black defaults" {
  "$REPO_ROOT/theme" black >/dev/null
  f="$HOME/.cache/theme/Xresources"
  grep -qx "note.color1: #4a4435" "$f"
  grep -qx "note.color2: #3d4136" "$f"
  grep -qx "note.color3: #383e43" "$f"
  grep -qx "note.color4: #483533" "$f"
}
