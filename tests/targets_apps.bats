#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  setup_fake_home
  unset DISPLAY
}

teardown() { teardown_fake_home; }

@test "opencode gets a dots theme and tui.json selects it" {
  "$REPO_ROOT/theme" white >/dev/null
  f="$HOME/.config/opencode/themes/dots.json"
  [ "$(jq -r .theme.background "$f")" = "#e8e6e1" ]
  [ "$(jq -r .theme.text "$f")" = "#3a3633" ]
  [ "$(jq -r '.theme | length' "$f")" -ge 49 ]
  [ "$(jq -r .theme "$HOME/.config/opencode/tui.json")" = "dots" ]
}

@test "opencode tui.json keeps its other settings" {
  mkdir -p "$HOME/.config/opencode"
  echo '{"plugin":["a"],"theme":"gruvbox"}' > "$HOME/.config/opencode/tui.json"
  "$REPO_ROOT/theme" white >/dev/null
  [ "$(jq -r '.plugin[0]' "$HOME/.config/opencode/tui.json")" = "a" ]
  [ "$(jq -r .theme "$HOME/.config/opencode/tui.json")" = "dots" ]
}

@test "btop gets a dots theme and btop.conf selects it, keeping other settings" {
  mkdir -p "$HOME/.config/btop"
  printf 'color_theme = "Default"\nupdate_ms = 1500\n' > "$HOME/.config/btop/btop.conf"
  "$REPO_ROOT/theme" white >/dev/null
  grep -qx 'theme\[main_bg\]="#e8e6e1"' "$HOME/.config/btop/themes/dots.theme"
  grep -qx 'color_theme = "dots"' "$HOME/.config/btop/btop.conf"
  grep -qx 'update_ms = 1500' "$HOME/.config/btop/btop.conf"
  [ "$(grep -c '^color_theme' "$HOME/.config/btop/btop.conf")" -eq 1 ]
}

@test "btop.conf is created when btop has never run" {
  "$REPO_ROOT/theme" white >/dev/null
  grep -qx 'color_theme = "dots"' "$HOME/.config/btop/btop.conf"
}

@test "rmpc gets a dots theme only when it is configured, and config.ron selects it" {
  "$REPO_ROOT/theme" white >/dev/null
  [ ! -e "$HOME/.config/rmpc" ]
  mkdir -p "$HOME/.config/rmpc"
  printf '(\n    address: "127.0.0.1:6600",\n)\n' > "$HOME/.config/rmpc/config.ron"
  "$REPO_ROOT/theme" white >/dev/null
  grep -q 'background_color: "#e8e6e1",' "$HOME/.config/rmpc/themes/dots.ron"
  grep -q 'theme: Some("dots"),' "$HOME/.config/rmpc/config.ron"
  grep -q 'address: "127.0.0.1:6600"' "$HOME/.config/rmpc/config.ron"
  "$REPO_ROOT/theme" black >/dev/null
  [ "$(grep -c 'theme: Some' "$HOME/.config/rmpc/config.ron")" -eq 1 ]
}

@test "gtk 3 and 4 import the theme and keep what the user wrote" {
  mkdir -p "$HOME/.config/gtk-3.0"
  echo 'label { font-weight: bold; }' > "$HOME/.config/gtk-3.0/gtk.css"
  "$REPO_ROOT/theme" white >/dev/null
  "$REPO_ROOT/theme" black >/dev/null
  for v in 3 4; do
    css="$HOME/.config/gtk-$v.0/gtk.css"
    [ "$(grep -c '@import' "$css")" -eq 1 ]
    grep -q "$HOME/.cache/theme/gtk$v.css" "$css"
    grep -q '#161717' "$HOME/.cache/theme/gtk$v.css"
  done
  grep -q 'font-weight: bold' "$HOME/.config/gtk-3.0/gtk.css"
  grep -q '@define-color window_bg_color #161717;' "$HOME/.cache/theme/gtk4.css"
}

@test "gtk prefers dark for dark themes and light for white" {
  mkdir -p "$HOME/.config/gtk-3.0"
  printf '[Settings]\ngtk-theme-name=HighContrastInverse\ngtk-font-name=Sans 11\n' > "$HOME/.config/gtk-3.0/settings.ini"
  "$REPO_ROOT/theme" black >/dev/null
  f="$HOME/.config/gtk-3.0/settings.ini"
  grep -qx 'gtk-theme-name=Adwaita' "$f"
  grep -qx 'gtk-application-prefer-dark-theme=1' "$f"
  grep -qx 'gtk-font-name=Sans 11' "$f"
  "$REPO_ROOT/theme" white >/dev/null
  grep -qx 'gtk-application-prefer-dark-theme=0' "$f"
  [ "$(grep -c 'prefer-dark' "$f")" -eq 1 ]
  grep -qx 'gtk-application-prefer-dark-theme=0' "$HOME/.config/gtk-4.0/settings.ini"
}

@test "bash takes fzf and ls colors from the theme" {
  "$REPO_ROOT/theme" white >/dev/null
  ln -s "$REPO_ROOT/home/bashrc" "$HOME/.bashrc"
  run bash -ic 'printf "%s\n%s\n%s" "$FZF_DEFAULT_OPTS" "$LS_COLORS" "$BAT_THEME"' 2>/dev/null
  [[ "$output" == *"bg:#e8e6e1"* ]]
  [[ "$output" == *"di=1;38;2;95;106;44"* ]]
  [[ "$output" == *"ansi"* ]]
  grep -qE "color=.(fg|bg|hl):#" "$REPO_ROOT/home/bashrc" && return 1; true
}

@test "qt5ct and qt6ct get a dots palette and select it with fusion" {
  mkdir -p "$HOME/.config/qt5ct"
  printf '[Appearance]\nstyle=kvantum\n\n[Fonts]\nfixed="Mono,10"\n' > "$HOME/.config/qt5ct/qt5ct.conf"
  "$REPO_ROOT/theme" white >/dev/null
  for v in 5 6; do
    d="$HOME/.config/qt${v}ct"
    line=$(grep '^active_colors=' "$d/colors/dots.conf")
    [ "$(tr ',' '\n' <<<"${line#*=}" | wc -l)" -eq 21 ]
    [[ "$line" == "active_colors=#ff3a3633, "* ]]
    grep -q '^disabled_colors=#ff9a948d' "$d/colors/dots.conf"
    grep -qx "color_scheme_path=$d/colors/dots.conf" "$d/qt${v}ct.conf"
    grep -qx 'custom_palette=true' "$d/qt${v}ct.conf"
    grep -qx 'style=Fusion' "$d/qt${v}ct.conf"
    grep -qx 'icon_theme=breeze' "$d/qt${v}ct.conf"
  done
  grep -qx 'fixed="Mono,10"' "$HOME/.config/qt5ct/qt5ct.conf"
  [ "$(grep -c '^style=' "$HOME/.config/qt5ct/qt5ct.conf")" -eq 1 ]
  "$REPO_ROOT/theme" black >/dev/null
  grep -qx 'icon_theme=breeze-dark' "$HOME/.config/qt6ct/qt6ct.conf"
}

@test "the X session asks Qt to use qt5ct, before anything starts" {
  f="$REPO_ROOT/home/xinitrc"
  qt_n=$(grep -n '^export QT_QPA_PLATFORMTHEME=qt5ct$' "$f" | cut -d: -f1)
  theme_n=$(grep -n '^theme ' "$f" | cut -d: -f1)
  [ -n "$qt_n" ]
  [ "$qt_n" -lt "$theme_n" ]
}

@test "gimp gets a dots theme on top of its own styles, and gimprc selects it" {
  export GIMP_DATA="$BATS_TEST_TMPDIR/gimp"
  mkdir -p "$GIMP_DATA/themes/Default" "$HOME/.config/GIMP/3.2"
  touch "$GIMP_DATA/themes/Default/common-dark.css" "$GIMP_DATA/themes/Default/common-light.css"
  printf '(config-version "3.2.6")\n(theme "Default")\n\n# end of gimprc\n' > "$HOME/.config/GIMP/3.2/gimprc"
  "$REPO_ROOT/theme" black >/dev/null
  t="$HOME/.config/GIMP/3.2/themes/dots"
  for f in gimp gimp-dark gimp-gray gimp-light; do
    grep -q '@define-color bg-color #161717;' "$t/$f.css"
    grep -qF "@import url(\"file://$GIMP_DATA/themes/Default/common-dark.css\");" "$t/$f.css"
  done
  g="$HOME/.config/GIMP/3.2/gimprc"
  grep -qx '(theme "dots")' "$g"
  grep -qx '(theme-scheme dark)' "$g"
  grep -qx '(config-version "3.2.6")' "$g"
  "$REPO_ROOT/theme" white >/dev/null
  grep -qx '(theme-scheme light)' "$g"
  grep -q 'common-light.css' "$t/gimp.css"
  [ "$(grep -c '^(theme ' "$g")" -eq 1 ]
  [ "$(grep -c '^(theme-scheme ' "$g")" -eq 1 ]
}

@test "gimp is left alone when it has never run" {
  export GIMP_DATA="$BATS_TEST_TMPDIR/gimp"
  "$REPO_ROOT/theme" black >/dev/null
  [ ! -e "$HOME/.config/GIMP" ]
}

@test "kdenlive gets a dots color scheme and kdenliverc selects it" {
  mkdir -p "$HOME/.config"
  printf '[UiSettings]\nColorScheme=KvMojave\nColorSchemePath=KvMojave.colors\n\n[misc]\nkeep=1\n' > "$HOME/.config/kdenliverc"
  "$REPO_ROOT/theme" black >/dev/null
  f="$HOME/.local/share/color-schemes/dots.colors"
  grep -qx 'BackgroundNormal=22,23,23' "$f"
  grep -qx 'Name=dots' "$f"
  for s in Window View Button Selection Tooltip Header Complementary; do grep -qx "\[Colors:$s\]" "$f"; done
  grep -qx 'ColorScheme=dots' "$HOME/.config/kdenliverc"
  grep -qx 'ColorSchemePath=dots.colors' "$HOME/.config/kdenliverc"
  grep -qx 'keep=1' "$HOME/.config/kdenliverc"
}

@test "kdenlive is left alone when it has never run" {
  "$REPO_ROOT/theme" black >/dev/null
  [ ! -e "$HOME/.config/kdenliverc" ]
  [ ! -e "$HOME/.local/share/color-schemes/dots.colors" ]
}

@test "obs gets a dots variant of yami and user.ini selects it" {
  mkdir -p "$HOME/.config/obs-studio"
  printf '[General]\nFirstRun=true\n' > "$HOME/.config/obs-studio/user.ini"
  "$REPO_ROOT/theme" black >/dev/null
  t="$HOME/.config/obs-studio/themes/Yami_dots.ovt"
  grep -q "id: 'com.obsproject.Yami.dots';" "$t"
  grep -q "extends: 'com.obsproject.Yami';" "$t"
  grep -q -- '--bg_window: #161717;' "$t"
  grep -qx 'Theme=com.obsproject.Yami.dots' "$HOME/.config/obs-studio/user.ini"
  grep -qx 'FirstRun=true' "$HOME/.config/obs-studio/user.ini"
  "$REPO_ROOT/theme" white >/dev/null
  grep -q "extends: 'com.obsproject.Yami.Light';" "$t"
  grep -q "dark: 'false';" "$t"
}

@test "obs is left alone when it has never run" {
  "$REPO_ROOT/theme" black >/dev/null
  [ ! -e "$HOME/.config/obs-studio" ]
}

@test "qt gets a readable default font once, and keeps a font the user chose" {
  mkdir -p "$HOME/.config/qt5ct"
  printf '[Fonts]\nfixed="Mono,11"\n' > "$HOME/.config/qt5ct/qt5ct.conf"
  "$REPO_ROOT/theme" black >/dev/null
  "$REPO_ROOT/theme" white >/dev/null
  grep -qx 'general="Noto Sans,10"' "$HOME/.config/qt5ct/qt5ct.conf"
  grep -qx 'fixed="Mono,11"' "$HOME/.config/qt5ct/qt5ct.conf"
  grep -qx 'general="Noto Sans,10"' "$HOME/.config/qt6ct/qt6ct.conf"
  grep -qx 'fixed="monospace,10"' "$HOME/.config/qt6ct/qt6ct.conf"
  [ "$(grep -c '^general=' "$HOME/.config/qt6ct/qt6ct.conf")" -eq 1 ]
}
