#!/usr/bin/env bash

render_btop() {
  local dir="$HOME/.config/btop" conf
  mkdir -p "$dir/themes"
  cat > "$dir/themes/dots.theme" <<BTOP
theme[main_bg]="$bg"
theme[main_fg]="$fg"
theme[title]="$fg"
theme[hi_fg]="$accent"
theme[selected_bg]="$bg3"
theme[selected_fg]="$fg"
theme[inactive_fg]="$fg3"
theme[graph_text]="$fg2"
theme[meter_bg]="$line"
theme[proc_misc]="$fg1"
theme[cpu_box]="$line"
theme[mem_box]="$line"
theme[net_box]="$line"
theme[proc_box]="$line"
theme[div_line]="$line"
theme[temp_start]="$green"
theme[temp_mid]="$accent"
theme[temp_end]="$red"
theme[cpu_start]="$green"
theme[cpu_mid]="$accent"
theme[cpu_end]="$red"
theme[free_start]="$green"
theme[free_mid]="$green"
theme[free_end]="$green_light"
theme[cached_start]="$blue"
theme[cached_mid]="$blue"
theme[cached_end]="$color12"
theme[available_start]="$accent"
theme[available_mid]="$accent"
theme[available_end]="$accent_light1"
theme[used_start]="$red"
theme[used_mid]="$red"
theme[used_end]="$color9"
theme[download_start]="$blue"
theme[download_mid]="$color6"
theme[download_end]="$color14"
theme[upload_start]="$color5"
theme[upload_mid]="$accent"
theme[upload_end]="$accent_light1"
theme[process_start]="$green"
theme[process_mid]="$accent"
theme[process_end]="$red"
BTOP
  conf="$dir/btop.conf"
  if [[ -f "$conf" ]] && grep -q '^color_theme' "$conf"; then
    sed -i 's|^color_theme.*|color_theme = "dots"|' "$conf"
  else
    printf 'color_theme = "dots"\n' >> "$conf"
  fi
}

reload_btop() {
  pgrep -x btop >/dev/null || return 0
  info "btop: restart it to see the new theme"
}
