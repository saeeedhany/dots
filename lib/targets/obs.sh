#!/usr/bin/env bash

render_obs() {
  local dir="$HOME/.config/obs-studio" base=com.obsproject.Yami dark=true
  [[ -f "$dir/user.ini" ]] || return 0
  theme_dark || { base=com.obsproject.Yami.Light; dark=false; }
  mkdir -p "$dir/themes"
  cat > "$dir/themes/Yami_dots.ovt" <<OBS
@OBSThemeMeta {
    name: 'dots';
    id: 'com.obsproject.Yami.dots';
    extends: '$base';
    author: 'saeeedhany';
    dark: '$dark';
}

@OBSThemeVars {
    --grey1: $line2;
    --grey2: $line;
    --grey3: $bg3;
    --grey4: $bg2;
    --grey5: $bg2;
    --grey6: $bg1;
    --grey7: $bg;
    --grey8: $bg;

    --bg_window: $bg;
    --bg_base: $bg1;
    --bg_preview: $bg;

    --primary: $line2;
    --primary_light: $fg3;
    --primary_lighter: $fg2;
    --primary_dark: $line;
    --primary_darker: $bg3;
    --highlight_color: $accent;

    --warning: $color3;
    --danger: $red;

    --text: $fg;
    --text_light: $fg;
    --text_muted: $fg2;
    --text_disabled: $fg3;
    --text_inactive: $fg1;
}
OBS
  ini_set "$dir/user.ini" Appearance Theme com.obsproject.Yami.dots
}

reload_obs() {
  pgrep -x obs >/dev/null || return 0
  info "obs: restart it to see the new theme"
}
