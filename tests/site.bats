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

sitejs() {
  SITE_JS="${SITE_JS:-$REPO_ROOT/site.js}" STORAGE="$1" node -e '
    const vm = require("vm");
    const fs = require("fs");
    const noop = () => {};
    const store = process.env.STORAGE === "blocked"
      ? { getItem() { throw new Error("blocked"); }, setItem() { throw new Error("blocked"); } }
      : { getItem: () => process.env.STORAGE || null, setItem: noop };
    const ctx = {
      document: { documentElement: { dataset: {} }, addEventListener: noop, querySelector: () => null, querySelectorAll: () => [] },
      window: { addEventListener: noop },
      localStorage: store,
      getComputedStyle: () => ({ getPropertyValue: () => "" }),
      navigator: {}, setTimeout, clearTimeout, setInterval: noop,
    };
    const out = vm.runInNewContext(fs.readFileSync(process.env.SITE_JS, "utf8") +
      "\n;JSON.stringify({ theme: document.documentElement.dataset.theme, themes: THEMES })", ctx);
    process.stdout.write(out);
  '
}

@test "with storage blocked the page still loads, in black" {
  [ "$(sitejs blocked | jq -r .theme)" = black ]
}

@test "a saved theme loads, and an unknown one falls back to black" {
  [ "$(sitejs blue | jq -r .theme)" = blue ]
  [ "$(sitejs nope | jq -r .theme)" = black ]
}

@test "the theme picker names and strip colors match the theme files" {
  local json n k i
  json="$(sitejs "")"
  [ "$(jq -r '.themes | keys | join(" ")' <<<"$json")" = "$(theme_names | paste -sd' ')" ]
  while read -r n; do
    i=1
    for k in bg fg accent green red color5; do
      [ "$(jq -r --arg n "$n" --argjson i "$i" '.themes[$n][$i]' <<<"$json")" = "$(sed -n "s/^$k=//p" "$REPO_ROOT/themes/$n" | tr 'A-F' 'a-f')" ] ||
        { echo "$n $k drifted"; return 1; }
      i=$((i + 1))
    done
  done < <(theme_names)
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

@test "the blog index links every post and home" {
  local f="$REPO_ROOT/blog/index.html" p n=0
  [ -f "$f" ]
  grep -qF 'href="../"' "$f"
  for p in "$REPO_ROOT"/blog/*.html; do
    [[ "$(basename "$p")" == index.html ]] && continue
    n=$((n + 1))
    grep -qF "href=\"$(basename "$p")\"" "$f" || { echo "not linked: $p"; return 1; }
    grep -qF 'href="./"' "$p" || { echo "no link to the index: $p"; return 1; }
  done
  [ "$n" -ge 1 ]
}

@test "home links the design page and the blog from the bar and the design section" {
  local f="$REPO_ROOT/index.html"
  [ "$(grep -cF 'href="design.html"' "$f")" -ge 2 ]
  grep -qF 'href="blog/"' "$f"
}

@test "the pages make no claims the code contradicts" {
  cd "$REPO_ROOT"
  ! grep -qi 'current tag' design.html blog/one-machine.html
  ! grep -q 'the master window' design.html
  ! grep -q '<code>gd</code> for definition' blog/one-machine.html
  ! grep -q 'only place a hex value' design.html
  ! grep -q 'htop' design.html index.html
  ! grep -q 'powerline arrow' blog/one-machine.html
  ! grep -q 'every generated text color' design.html
  ! grep -q 'skips the rule' design.html
  ! grep -q 'plain accent text, not bold' design.html
  ! grep -q 'the repo holds only what a person wrote' blog/one-machine.html
  ! grep -q 'refuses a theme with a missing color or text that is hard to read' index.html
  grep -q 'gruvbox.nvim' design.html
  grep -q 'gruvbox.nvim' blog/one-machine.html
  grep -q '<code>ls</code>' design.html
  ! grep -q 'old exception\|older than this system' design.html
}

@test "every page can switch the theme and follows other tabs" {
  local p
  for p in $(pages); do
    grep -qE 'id="(themelist|picker)"' "$p" || { echo "no picker: $p"; return 1; }
  done
  grep -q "addEventListener('storage'" "$REPO_ROOT/site.js"
}

@test "diagram labels are not the dimmest text" {
  ! grep -qE '^\.arrow \{[^}]*var\(--fg3\)' "$REPO_ROOT/site.css"
}

@test "packages.txt gains no new comments for emacs" {
  ! grep -q 'emacs, its language servers' "$REPO_ROOT/packages/pacman.txt"
}

@test "the install notice shows on every visit, minimizes to a chip, and changes in the install section" {
  grep -q 'id="install"' "$REPO_ROOT/index.html"
  grep -q 'id="install-cmd"' "$REPO_ROOT/index.html"
  grep -qF "'index.html#install'" "$REPO_ROOT/site.js"
  ! grep -qF "'seen'" "$REPO_ROOT/site.js"
  grep -qF "localStorage.setItem('dots-install', 'min')" "$REPO_ROOT/site.js"
  grep -qF 'aria-label="minimize"' "$REPO_ROOT/site.js"
  grep -qF 'you found it' "$REPO_ROOT/site.js"
  grep -qF "#install-cmd .copy" "$REPO_ROOT/site.js"
  grep -q '^\.notes {' "$REPO_ROOT/site.css"
  grep -q '^\.hint\.min' "$REPO_ROOT/site.css"
  grep -q '^\.block\.lit' "$REPO_ROOT/site.css"
}
