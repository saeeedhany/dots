#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  setup_fake_home
  unset VISUAL
  SL="$BATS_TEST_TMPDIR/suckless"
  export SUCKLESS_DIR="$SL"
  for t in dwm st dmenu; do fake_tool "$t" config.def.h; done
  fake_tool dwmblocks blocks.def.h
  printf 'all install:\n\tfor t in dwm st dmenu dwmblocks; do $(MAKE) -C $$t $@ || exit 1; done\n' > "$SL/Makefile"
}

teardown() { teardown_fake_home; }

fake_tool() {
  mkdir -p "$SL/$1"
  printf 'setting\n' > "$SL/$1/$2"
  printf 'all:\ninstall:\n\tmkdir -p $(HOME)/.local/bin\n\tcp %s $(HOME)/.local/bin/%s\n' "$2" "$1" > "$SL/$1/Makefile"
}

editor() {
  local e="$BATS_TEST_TMPDIR/editor"
  printf '#!/bin/sh\nprintf "%%s\\n" "$1" > "%s/opened"\n%s\n' "$BATS_TEST_TMPDIR" "$1" > "$e"
  chmod +x "$e"
  printf '%s' "$e"
}

@test "suckless dwm opens config.def.h, then builds and installs dwm" {
  EDITOR="$(editor 'echo changed >> "$1"')" run "$REPO_ROOT/bin/suckless" dwm
  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TEST_TMPDIR/opened")" = "$SL/dwm/config.def.h" ]
  grep -q changed "$HOME/.local/bin/dwm"
}

@test "dwmblocks opens blocks.def.h" {
  EDITOR="$(editor 'echo changed >> "$1"')" run "$REPO_ROOT/bin/suckless" dwmblocks
  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TEST_TMPDIR/opened")" = "$SL/dwmblocks/blocks.def.h" ]
  [ -f "$HOME/.local/bin/dwmblocks" ]
}

@test "an unchanged file builds nothing" {
  EDITOR="$(editor ':')" run "$REPO_ROOT/bin/suckless" st
  [ "$status" -eq 0 ]
  [[ "$output" == *"no change"* ]]
  [ ! -e "$HOME/.local/bin/st" ]
}

@test "-n builds without opening the editor" {
  EDITOR=false run "$REPO_ROOT/bin/suckless" dmenu -n
  [ "$status" -eq 0 ]
  [ -f "$HOME/.local/bin/dmenu" ]
}

@test "no tool builds and installs every tool" {
  run "$REPO_ROOT/bin/suckless"
  [ "$status" -eq 0 ]
  for t in dwm st dmenu dwmblocks; do
    [ -f "$HOME/.local/bin/$t" ] || { echo "missing $t"; return 1; }
  done
}

@test "a failed build installs nothing and says so" {
  printf 'all:\n\tfalse\ninstall: all\n\tcp config.def.h $(HOME)/.local/bin/dwm\n' > "$SL/dwm/Makefile"
  run "$REPO_ROOT/bin/suckless" dwm -n
  [ "$status" -ne 0 ]
  [[ "$output" == *"dwm"* ]]
  [ ! -e "$HOME/.local/bin/dwm" ]
}

@test "an unknown tool exits with usage" {
  run "$REPO_ROOT/bin/suckless" xterm
  [ "$status" -ne 0 ]
  [[ "$output" == *"usage"* ]]
}

@test "a missing suckless folder is reported" {
  SUCKLESS_DIR="$BATS_TEST_TMPDIR/none" run "$REPO_ROOT/bin/suckless" dwm -n
  [ "$status" -ne 0 ]
  [[ "$output" == *"none"* ]]
}

@test "old root copies are reported once, with the command that removes them" {
  mkdir -p "$BATS_TEST_TMPDIR/old/bin"
  touch "$BATS_TEST_TMPDIR/old/bin/dwm" "$BATS_TEST_TMPDIR/old/bin/st"
  SUCKLESS_OLD_PREFIX="$BATS_TEST_TMPDIR/old" run "$REPO_ROOT/bin/suckless"
  [ "$status" -eq 0 ]
  [ "$(grep -c 'old copy' <<<"$output")" -eq 1 ]
  [[ "$output" == *"dwm st"* ]]
  [[ "$output" == *"uninstall PREFIX=$BATS_TEST_TMPDIR/old"* ]]
}
