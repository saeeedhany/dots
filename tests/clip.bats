#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  setup_fake_home
  FAKE="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$FAKE"
  cat > "$FAKE/xclip" <<XCLIP
#!/bin/sh
case "\$*" in
  *-o*TARGETS*) cat "$BATS_TEST_TMPDIR/targets" ;;
  *-o*) cat "$BATS_TEST_TMPDIR/text" ;;
  *-i*) cat "\${@: -1}" > "$BATS_TEST_TMPDIR/set" 2>/dev/null || cat > "$BATS_TEST_TMPDIR/set" ;;
  *) cat > "$BATS_TEST_TMPDIR/set" ;;
esac
XCLIP
  chmod +x "$FAKE/xclip"
  export PATH="$FAKE:$PATH"
  CLIPDIR="$XDG_RUNTIME_DIR/clip"
}

teardown() { teardown_fake_home; }

copy() {
  printf '%s' "$1" > "$BATS_TEST_TMPDIR/text"
  printf '%s\n' "${2:-TARGETS UTF8_STRING STRING}" | tr ' ' '\n' > "$BATS_TEST_TMPDIR/targets"
  "$REPO_ROOT/bin/clip" save
  sleep 0.01
}

menu() {
  printf '#!/bin/sh\ncat > "%s/menu"\nsed -n "%sp" "%s/menu"\n' "$BATS_TEST_TMPDIR" "$1" "$BATS_TEST_TMPDIR" > "$FAKE/dmenu"
  chmod +x "$FAKE/dmenu"
  "$REPO_ROOT/bin/clip"
}

@test "copied text is kept, newest first, without duplicates" {
  copy "first"; copy "second"; copy "first"
  menu 0
  [ "$(cat "$BATS_TEST_TMPDIR/menu")" = "$(printf '1  first\n2  second')" ]
}

@test "picking an entry puts its whole text back on the clipboard and moves it to the top" {
  copy "$(printf 'line one\nline two\nline three')"; copy "other"
  menu 2
  [ "$(cat "$BATS_TEST_TMPDIR/set")" = "$(printf 'line one\nline two\nline three')" ]
  menu 0
  [ "$(head -1 "$BATS_TEST_TMPDIR/menu")" = "1  line one  (+2 lines)" ]
}

@test "images, blank text and password manager copies are not kept" {
  copy "x" "TARGETS image/png"
  copy "   " 
  copy "secret" "TARGETS UTF8_STRING x-kde-passwordManagerHint"
  [ -z "$(ls -A "$CLIPDIR" 2>/dev/null)" ]
}

@test "history lives in the runtime folder, private, and keeps the newest 200" {
  for i in $(seq 205); do printf 'entry %s' "$i" > "$BATS_TEST_TMPDIR/text"; printf 'UTF8_STRING\n' > "$BATS_TEST_TMPDIR/targets"; "$REPO_ROOT/bin/clip" save; done
  [ "$(ls "$CLIPDIR" | wc -l)" -eq 200 ]
  [ "$(stat -c %a "$CLIPDIR")" = 700 ]
  grep -rqx 'entry 205' "$CLIPDIR"
  ! grep -rqx 'entry 1' "$CLIPDIR"
}

@test "escaping the menu changes nothing" {
  copy "keep"
  menu 99
  [ ! -e "$BATS_TEST_TMPDIR/set" ]
}

@test "super v opens the history and xinitrc starts the daemon" {
  grep -A1 -x 'super + v' "$REPO_ROOT/config/sxhkd/sxhkdrc" | tail -1 | grep -qx '    clip'
  grep -qx 'command -v clipnotify >/dev/null && clip daemon &' "$REPO_ROOT/home/xinitrc"
  grep -qx 'clipnotify' "$REPO_ROOT/packages/pacman.txt"
}
