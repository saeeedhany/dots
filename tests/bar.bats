#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  HW="$BATS_TEST_TMPDIR/hwmon"
  mkdir -p "$HW/hwmon0" "$HW/hwmon1"
  echo acpitz > "$HW/hwmon0/name"
  echo 27800 > "$HW/hwmon0/temp1_input"
}

cpu() { HWMON="$HW" "$REPO_ROOT/config/dwmblocks/scripts/cpu_temp.sh"; }

@test "cpu temperature comes from the k10temp sensor in whole degrees" {
  echo k10temp > "$HW/hwmon1/name"
  echo 48875 > "$HW/hwmon1/temp1_input"
  [ "$(cpu)" = "48°C" ]
}

@test "intel's coretemp works the same way" {
  echo coretemp > "$HW/hwmon1/name"
  echo 61000 > "$HW/hwmon1/temp1_input"
  [ "$(cpu)" = "61°C" ]
}

@test "no cpu sensor prints nothing instead of failing" {
  run cpu
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "the temperature does not call sensors" {
  ! grep -q 'sensors' "$REPO_ROOT/config/dwmblocks/scripts/cpu_temp.sh"
}

@test "the volume keys tell the bar right away" {
  local f="$REPO_ROOT/config/sxhkd/sxhkdrc" n
  n=$(grep -c 'pactl set-sink-volume @DEFAULT_SINK@ [+-]5% && pkill -RTMIN+10 -x dwmblocks$' "$f")
  [ "$n" -eq 2 ]
}

@test "xinitrc starts kbsignal right after the bar" {
  local f="$REPO_ROOT/home/xinitrc"
  [ "$(grep -A1 -x 'dwmblocks &' "$f" | tail -1)" = "kbsignal &" ]
}
