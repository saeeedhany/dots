#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  setup_fake_home
  command -v Xvfb >/dev/null || skip "Xvfb not installed"
  export DISPLAY=:96
  Xvfb :96 -screen 0 640x480x24 -nolisten tcp >/dev/null 2>&1 & XVFB_PID=$!
  for i in $(seq 50); do xdpyinfo >/dev/null 2>&1 && break; sleep 0.1; done
  mkdir -p "$HOME/Pictures" "$BATS_TEST_TMPDIR/bin"
  printf '#!/bin/sh\necho "$*" > "%s/notified"\n' "$BATS_TEST_TMPDIR" > "$BATS_TEST_TMPDIR/bin/notify-send"
  chmod +x "$BATS_TEST_TMPDIR/bin/notify-send"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}

teardown() {
  kill "$XVFB_PID" 2>/dev/null || true
  wait "$XVFB_PID" 2>/dev/null || true
  teardown_fake_home
}

@test "super s saves the screenshot and puts the image on the clipboard" {
  cmd="$(grep -A1 -x 'super + s' "$REPO_ROOT/config/sxhkd/sxhkdrc" | tail -1)"
  sh -c "$cmd"
  sleep 0.5
  ls "$HOME"/Pictures/screenshot_*.png >/dev/null
  xclip -o -selection clipboard -t TARGETS | grep -qx 'image/png'
  [ "$(xclip -o -selection clipboard -t image/png | head -c 8 | od -An -tx1 | tr -d ' \n')" = 89504e470d0a1a0a ]
  grep -q 'copied' "$BATS_TEST_TMPDIR/notified"
}

@test "super shift s does the same for a selected area" {
  grep -A1 -x 'super + shift + s' "$REPO_ROOT/config/sxhkd/sxhkdrc" | tail -1 |
    grep -qF "scrot -s ~/Pictures/screenshot_%Y-%m-%d-%H%M%S.png -e 'xclip -selection clipboard -t image/png -i \$f'"
}

@test "clip keeps real copied text, but not a screenshot" {
  printf 'hello from x' | xclip -selection clipboard -i
  sleep 0.3
  "$REPO_ROOT/bin/clip" save
  grep -rqx 'hello from x' "$XDG_RUNTIME_DIR/clip"
  printf '\x89PNG\r\n\x1a\n' | xclip -selection clipboard -t image/png -i
  sleep 0.3
  "$REPO_ROOT/bin/clip" save
  [ "$(ls "$XDG_RUNTIME_DIR/clip" | wc -l)" -eq 1 ]
}
