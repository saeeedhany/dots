#!/usr/bin/env bash

render_rmpc() {
  local dir="$HOME/.config/rmpc" conf
  conf="$dir/config.ron"
  [[ -f "$conf" ]] || return 0
  mkdir -p "$dir/themes"
  cat > "$dir/themes/dots.ron" <<RMPC
#![enable(implicit_some)]
#![enable(unwrap_newtypes)]
#![enable(unwrap_variant_newtypes)]
(
    background_color: "$bg",
    text_color: "$fg",
    header_background_color: "$bg",
    modal_background_color: "$bg",
    preview_label_style: (fg: "$accent"),
    preview_metadata_group_style: (fg: "$accent", modifiers: "Bold"),
    highlighted_item_style: (fg: "$accent", modifiers: "Bold"),
    current_item_style: (fg: "$bg", bg: "$accent", modifiers: "Bold"),
    borders_style: (fg: "$line"),
    highlight_border_style: (fg: "$fg2"),
    progress_bar: (
        symbols: ["█", "█", "█", " ", "█"],
        track_style: (fg: "$line"),
        elapsed_style: (fg: "$accent"),
        thumb_style: (fg: "$accent"),
    ),
    scrollbar: (
        symbols: ["│", "█", "▲", "▼"],
        track_style: (fg: "$line"),
        ends_style: (fg: "$line"),
        thumb_style: (fg: "$fg2"),
    ),
    tab_bar: (
        active_style: (fg: "$bg", bg: "$accent", modifiers: "Bold"),
        inactive_style: (fg: "$fg2"),
    ),
)
RMPC
  if grep -q '^[[:space:]]*theme:' "$conf"; then
    sed -i 's|^\([[:space:]]*\)theme:.*|\1theme: Some("dots"),|' "$conf"
  else
    sed -i '0,/^(/s//(\n    theme: Some("dots"),/' "$conf"
  fi
}

reload_rmpc() {
  pgrep -x rmpc >/dev/null || return 0
  info "rmpc: restart it to see the new theme"
}
