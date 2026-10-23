#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  source "$REPO_ROOT/lib/log.sh"
  source "$REPO_ROOT/lib/theme.sh"
}

pages() {
  local f
  for f in "$REPO_ROOT"/*.html "$REPO_ROOT"/blog/*.html; do
    [[ -f "$f" ]] && printf '%s\n' "$f"
  done
}

theme_block() {
  awk -v sel="[data-theme=\"$1\"]" 'index($0, sel) { on = 1 } on { print } on && /}/ { exit }' "$REPO_ROOT/site.css"
}

@test "site.css carries every theme key with the theme file's value" {
  local n key val block
  while read -r n; do
    block="$(theme_block "$n")"
    [ -n "$block" ] || { echo "no block for $n"; return 1; }
    while read -r key val; do
      grep -qF -- "--$key: ${val,,};" <<<"$block" || { echo "$n: --$key should be ${val,,}"; return 1; }
    done < <(_theme_parse "$REPO_ROOT/themes/$n")
  done < <(theme_names)
}

@test "every page links the shared css and js" {
  local p prefix
  while read -r p; do
    prefix=""
    [[ "$p" == */blog/* ]] && prefix="../"
    grep -qF "href=\"${prefix}site.css\"" "$p" || { echo "no css: $p"; return 1; }
    grep -qF "src=\"${prefix}site.js\"" "$p" || { echo "no js: $p"; return 1; }
  done < <(pages)
}

@test "pages and shared files have no em or en dashes" {
  local f
  for f in $(pages) "$REPO_ROOT/site.css" "$REPO_ROOT/site.js"; do
    [ -f "$f" ] || { echo "missing: $f"; return 1; }
    ! grep -n $'\xe2\x80\x94\|\xe2\x80\x93' "$f" || { echo "dash in $f"; return 1; }
  done
}

@test "the theme survives without storage" {
  grep -q 'try' "$REPO_ROOT/site.js"
  grep -q "localStorage.getItem('dots-theme')" "$REPO_ROOT/site.js"
  grep -q "localStorage.setItem('dots-theme'" "$REPO_ROOT/site.js"
}

@test "the design page shows every token with its live value" {
  local f="$REPO_ROOT/design.html" key
  [ -f "$f" ]
  for key in "${THEME_KEYS[@]}"; do
    grep -qF "data-hex=\"$key\"" "$f" || { echo "no token: $key"; return 1; }
  done
}

@test "the design page has every section and links home" {
  local f="$REPO_ROOT/design.html" id
  for id in idea tokens rules syntax connect tricks yours; do
    grep -qF "id=\"$id\"" "$f" || { echo "no section: $id"; return 1; }
  done
  grep -qF 'href="./"' "$f"
}
