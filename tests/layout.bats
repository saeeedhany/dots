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
  ! grep -q 'Onyx.png' "$f"
  while read -r line; do
    [[ "$line" == "xrandr --query | grep -q '^HDMI-1-0 connected' && "* ]] || { echo "unguarded: $line"; return 1; }
  done < <(grep 'xrandr --output' "$f")
}

@test "xprofile runs no xrandr" {
  [ -f "$REPO_ROOT/home/xprofile" ]
  ! grep -q xrandr "$REPO_ROOT/home/xprofile"
}

@test "xinitrc sources local.sh, applies the theme, restores the wallpaper, then execs dwm last" {
  f="$REPO_ROOT/home/xinitrc"
  local_n=$(grep -nF '[ -f ~/.config/local.sh ] && . ~/.config/local.sh' "$f" | cut -d: -f1)
  theme_n=$(grep -nF 'theme "$(cat ~/.config/theme 2>/dev/null || echo grey)"' "$f" | cut -d: -f1)
  feh_n=$(grep -nF '[ -x ~/.fehbg ] && ~/.fehbg &' "$f" | cut -d: -f1)
  [ -n "$local_n" ] && [ -n "$theme_n" ] && [ -n "$feh_n" ]
  [ "$local_n" -lt "$theme_n" ] && [ "$theme_n" -lt "$feh_n" ]
  [ "$(grep -v '^[[:space:]]*$' "$f" | tail -1)" = "exec dbus-run-session dwm" ]
}

@test "vram scripts are silent without nvidia-smi" {
  for s in vram_usage.sh vram_temp.sh; do
    grep -qF 'command -v nvidia-smi >/dev/null || { echo N/A; exit 0; }' "$REPO_ROOT/config/dwmblocks/scripts/$s"
    run env PATH=/usr/bin/nonexistent /bin/sh "$REPO_ROOT/config/dwmblocks/scripts/$s"
    [ "$output" = "N/A" ]
  done
}

@test "local tools are vendored" {
  [ -x "$REPO_ROOT/bin/battery-monitor.sh" ]
  [ -x "$REPO_ROOT/bin/deasy" ]
  [ -x "$REPO_ROOT/bin/study/bin/study" ]
  [ ! -e "$REPO_ROOT/bin/study/logs/log.csv" ]
}
