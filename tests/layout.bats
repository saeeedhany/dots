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
