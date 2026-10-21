#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  setup_fake_home
  unset DISPLAY
  FF="$HOME/.mozilla/firefox"
  mkdir -p "$FF/abc.default-release" "$BATS_TEST_TMPDIR/elsewhere"
  cat > "$FF/profiles.ini" <<INI
[Profile1]
Name=default-release
IsRelative=1
Path=abc.default-release

[Profile0]
Name=Other
IsRelative=0
Path=$BATS_TEST_TMPDIR/elsewhere

[General]
StartWithLastProfile=1
INI
}

teardown() { teardown_fake_home; }

@test "every profile gets userChrome, userContent and the stylesheet pref" {
  "$REPO_ROOT/theme" blue >/dev/null
  for p in "$FF/abc.default-release" "$BATS_TEST_TMPDIR/elsewhere"; do
    grep -q '#1b1f27' "$p/chrome/userChrome.css"
    [ -f "$p/chrome/userContent.css" ]
    grep -qF 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' "$p/user.js"
  done
}

@test "user.js keeps existing lines and never duplicates the pref" {
  echo 'user_pref("a", 1);' > "$FF/abc.default-release/user.js"
  "$REPO_ROOT/theme" blue >/dev/null
  "$REPO_ROOT/theme" white >/dev/null
  grep -qF 'user_pref("a", 1);' "$FF/abc.default-release/user.js"
  [ "$(grep -c legacyUserProfileCustomizations "$FF/abc.default-release/user.js")" -eq 1 ]
}

@test "userContent only styles Firefox's own pages" {
  "$REPO_ROOT/theme" blue >/dev/null
  f="$FF/abc.default-release/chrome/userContent.css"
  # every rule must sit inside an @-moz-document block (brace depth >= 2)
  awk '
    /@-moz-document/ { doc = 1 }
    { for (i = 1; i <= length($0); i++) {
        ch = substr($0, i, 1)
        if (ch == "{") { depth++; if (depth == 1 && !doc) bad = 1 }
        if (ch == "}") { depth--; if (depth == 0) doc = 0 }
    } }
    END { exit bad }' "$f"
  grep -q 'url-prefix("about:")' "$f"
}

@test "no firefox profile yet is fine" {
  rm -rf "$HOME/.mozilla"
  run "$REPO_ROOT/theme" blue
  [ "$status" -eq 0 ]
  [[ "$output" == *"no profile yet"* ]]
}

@test "every target the theme command lists is implemented" {
  for t in wallpaper xresources dunst tmux bash zathura nvim vesktop firefox; do
    [ -f "$REPO_ROOT/lib/targets/$t.sh" ] || { echo "missing $t"; return 1; }
    grep -q "^render_$t()" "$REPO_ROOT/lib/targets/$t.sh"
    grep -q "^reload_$t()" "$REPO_ROOT/lib/targets/$t.sh"
  done
}

@test "profiles missing from profiles.ini (profile groups) are themed too" {
  mkdir -p "$FF/xyz.Profile 5"
  touch "$FF/xyz.Profile 5/prefs.js"
  "$REPO_ROOT/theme" blue >/dev/null
  grep -q '#1b1f27' "$FF/xyz.Profile 5/chrome/userChrome.css"
}

@test "zen profiles get the same files as firefox" {
  Z="$HOME/.config/zen"
  mkdir -p "$Z/z1.Default (release)"
  printf '[Profile0]\nName=Default (release)\nIsRelative=1\nPath=z1.Default (release)\n' > "$Z/profiles.ini"
  "$REPO_ROOT/theme" blue >/dev/null
  grep -q '#1b1f27' "$Z/z1.Default (release)/chrome/userChrome.css"
  grep -qF 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' "$Z/z1.Default (release)/user.js"
}
