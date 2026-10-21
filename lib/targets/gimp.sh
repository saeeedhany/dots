#!/usr/bin/env bash

gimp_rc_set() {
  local f="$1" key="$2" value="$3"
  if grep -q "^($key " "$f"; then
    sed -i "s|^($key .*|($key $value)|" "$f"
  elif grep -q '^# end of gimprc' "$f"; then
    sed -i "s|^# end of gimprc|($key $value)\n\n# end of gimprc|" "$f"
  else
    printf '(%s %s)\n' "$key" "$value" >> "$f"
  fi
}

render_gimp() {
  local data="${GIMP_DATA:-/usr/share/gimp/3.0}" dir variant=light scheme=light ruler f
  local dirs=("$HOME"/.config/GIMP/[0-9]*/)
  [[ -d "${dirs[0]}" ]] || return 0
  if theme_dark; then variant=dark; scheme=dark; fi
  [[ -f "$data/themes/Default/common-$variant.css" ]] || {
    warn "gimp: $data/themes/Default not found, skipping"
    return 0
  }
  ruler="rgba($(hex_rgb "$line"), 0.3)"
  for dir in "${dirs[@]}"; do
    [[ -f "$dir/gimprc" ]] || continue
    mkdir -p "$dir/themes/dots"
    for f in gimp gimp-dark gimp-gray gimp-light; do
      cat > "$dir/themes/dots/$f.css" <<GIMP
@define-color fg-color $fg;
@define-color bg-color $bg;
@define-color border-color $line;
@define-color dimmed-fg-color $fg1;
@define-color disabled-fg-color $fg3;
@define-color disabled-button-color $line2;
@define-color hover-color $bg3;
@define-color widget-bg-color $bg1;
@define-color selected-color $line;
@define-color extreme-bg-color $bg;
@define-color extreme-selected-color $bg3;
@define-color strong-border-color $line;
@define-color stronger-border-color $line2;
@define-color edge-border-color $bg;
@define-color scrollbar-slider-color $fg3;
@define-color scrollbar-trough-color $bg;
@define-color ruler-color $ruler;

@import url("file://$data/themes/Default/common-$variant.css");
GIMP
    done
    gimp_rc_set "$dir/gimprc" theme '"dots"'
    gimp_rc_set "$dir/gimprc" theme-scheme "$scheme"
  done
}

reload_gimp() {
  pgrep -x gimp >/dev/null || pgrep -f 'gimp-3' >/dev/null || return 0
  info "gimp: quit and start it again to see the new theme"
}
