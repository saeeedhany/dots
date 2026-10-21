#!/usr/bin/env bats

load test_helper

setup() { setup_repo_root; }

@test "old goofy paths are gone" {
  for p in xdots stColor Wallpapers bash tmux nvim; do
    [ ! -e "$REPO_ROOT/$p" ] || { echo "still exists: $p"; return 1; }
  done
}

@test "nvim is the machine's version" {
  [ -f "$REPO_ROOT/config/nvim/lua/plugins/snacks.lua" ]
  for f in diag explorer flash notify presence terminal todo; do
    [ ! -e "$REPO_ROOT/config/nvim/lua/plugins/$f.lua" ] || { echo "still exists: $f.lua"; return 1; }
  done
}

@test "xinitrc has no hardcoded wallpaper and every xrandr is guarded" {
  f="$REPO_ROOT/home/xinitrc"
  [ -f "$f" ]
  grep -q 'Onyx.png' "$f" && return 1
  while read -r line; do
    [[ "$line" == "xrandr --query | grep -q '^HDMI-1-0 connected' && "* ]] || { echo "unguarded: $line"; return 1; }
  done < <(grep 'xrandr --output' "$f")
}

@test "xinitrc sources local.sh, applies the theme, restores the wallpaper, then execs dwm last" {
  f="$REPO_ROOT/home/xinitrc"
  local_n=$(grep -nF '[ -f ~/.config/local.sh ] && . ~/.config/local.sh' "$f" | cut -d: -f1)
  theme_n=$(grep -nF 'theme "$(cat ~/.config/theme 2>/dev/null || echo grey)"' "$f" | cut -d: -f1)
  feh_n=$(grep -nF '[ -x ~/.fehbg ] && ~/.fehbg &' "$f" | cut -d: -f1)
  [ -n "$local_n" ]
  [ -n "$theme_n" ]
  [ -n "$feh_n" ]
  [ "$local_n" -lt "$theme_n" ]
  [ "$theme_n" -lt "$feh_n" ]
  [ "$(grep -v '^[[:space:]]*$' "$f" | tail -1)" = "exec dbus-run-session dwm" ]
}

@test "local tools are vendored" {
  [ -x "$REPO_ROOT/bin/battery-monitor.sh" ]
}

@test "bashrc loads ~/.config/local.bash last, for what only one machine needs" {
  f="$REPO_ROOT/home/bashrc"
  [ "$(grep -v '^[[:space:]]*$' "$f" | tail -1)" = '[[ -r ~/.config/local.bash ]] && . ~/.config/local.bash' ]
}

@test "bash_profile puts ~/.local/bin and ~/.cargo/bin on PATH once, local first" {
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
  run env -i HOME="$HOME" PATH=/usr/bin DISPLAY=:0 bash -c ". '$REPO_ROOT/home/bash_profile'; . '$REPO_ROOT/home/bash_profile'; printf %s \"\$PATH\""
  [ "$output" = "$HOME/.local/bin:$HOME/.cargo/bin:/usr/bin" ]
}

@test "xinitrc sets English and Arabic, switched with Alt+Shift, caps and escape swapped" {
  grep -qx "setxkbmap -layout us,ara -option '' -option caps:swapescape,grp:alt_shift_toggle" "$REPO_ROOT/home/xinitrc"
}

@test "the keyboard block says en or ar from the xkb group led" {
  stub="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$stub"
  for mask in 00000000:en 00001000:ar 00001002:ar 00000002:en; do
    printf '#!/bin/sh\necho "  auto repeat:  on    key click percent:  0    LED mask:  %s"\n' "${mask%%:*}" > "$stub/xset"
    chmod +x "$stub/xset"
    run env PATH="$stub:/usr/bin:/bin" sh "$REPO_ROOT/config/dwmblocks/scripts/keyboard"
    [ "$output" = "${mask##*:}" ]
  done
}
