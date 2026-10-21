#!/usr/bin/env bash
# Theme files: listing, loading, color math and readability checks.
# Sourced after lib/log.sh; needs REPO_ROOT.
# theme_load sets one variable per key (bg, fg, ...), so they are not
# assigned anywhere shellcheck can see.
# shellcheck disable=SC2154

THEME_KEYS=(
  bg bg1 bg2 bg3 line line2 fg fg1 fg2 fg3
  accent accent_light1 accent_light2
  accent_dark1 accent_dark2 accent_dark3 accent_dark4
  green green_light red red_dark blue cursor
  color0 color1 color2 color3 color4 color5 color6 color7
  color8 color9 color10 color11 color12 color13 color14 color15
)

theme_names() {
  local f
  for f in "$REPO_ROOT"/themes/*; do
    [[ -f "$f" ]] && basename "$f"
  done | sort
}

# _theme_parse <file>: prints "key value" for each key=value line.
# Theme files are parsed, never sourced, so they cannot run code.
_theme_parse() {
  sed -n -E 's/^[[:space:]]*([a-z0-9_]+)=([^[:space:]#]*([#][0-9a-fA-F]*)?)[[:space:]]*(#.*)?$/\1 \2/p' "$1"
}

# theme_load_file <file>: sets one shell variable per key, lowercased.
theme_load_file() {
  local file="$1" key val missing=() bad=()
  [[ -f "$file" ]] || { warn "no theme file: $file"; return 1; }
  local -A seen=()
  while read -r key val; do
    seen[$key]="$val"
  done < <(_theme_parse "$file")
  for key in "${THEME_KEYS[@]}"; do
    val="${seen[$key]:-}"
    if [[ -z "$val" ]]; then
      missing+=("$key")
    elif [[ ! "$val" =~ ^#[0-9a-fA-F]{6}$ ]]; then
      bad+=("$key=$val")
    fi
  done
  if [[ ${#missing[@]} -gt 0 || ${#bad[@]} -gt 0 ]]; then
    [[ ${#missing[@]} -gt 0 ]] && warn "$file: missing ${missing[*]}"
    [[ ${#bad[@]} -gt 0 ]] && warn "$file: not #rrggbb: ${bad[*]}"
    return 1
  fi
  for key in "${THEME_KEYS[@]}"; do
    printf -v "$key" '%s' "${seen[$key],,}"
  done
}

# theme_load <name>: loads themes/<name> and sets THEME
theme_load() {
  local name="$1"
  [[ "$name" =~ ^[a-z][a-z0-9-]*$ && -f "$REPO_ROOT/themes/$name" ]] || {
    warn "unknown theme: $name (have: $(theme_names | paste -sd' '))"
    return 1
  }
  theme_load_file "$REPO_ROOT/themes/$name" || return 1
  # shellcheck disable=SC2034 # read by the target renderers
  THEME="$name"
}

# hex_rgb <#hex>: "r, g, b" for CSS rgba()
hex_rgb() {
  local h="${1#\#}"
  printf '%d, %d, %d' "0x${h:0:2}" "0x${h:2:2}" "0x${h:4:2}"
}

# luminance <#hex>: WCAG relative luminance
luminance() {
  local h="${1#\#}"
  awk -v r="$((16#${h:0:2}))" -v g="$((16#${h:2:2}))" -v b="$((16#${h:4:2}))" '
    function lin(c) { c /= 255; return c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ^ 2.4 }
    BEGIN { printf "%.6f", 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b) }'
}

# contrast <#a> <#b>: WCAG contrast ratio, 2 decimals
contrast() {
  awk -v a="$(luminance "$1")" -v b="$(luminance "$2")" '
    BEGIN { if (a < b) { t = a; a = b; b = t }; printf "%.2f", (a + 0.05) / (b + 0.05) }'
}

# _at_least <ratio> <min>: true if ratio >= min
_at_least() { awk -v r="$1" -v m="$2" 'BEGIN { exit !(r >= m) }'; }

# theme_check <file>: prints every readability failure, returns 1 if any.
# Files marked "# canonical:" (gruvbox) keep their upstream palette and are
# only checked for fg on bg.
theme_check() {
  local file="$1" fails=() k r
  (
    theme_load_file "$file" || exit 1
    need() { # need <key> <min>
      r="$(contrast "${!1}" "$bg")"
      _at_least "$r" "$2" || fails+=("$1 ${!1} is $r:1 on bg, needs $2")
    }
    need fg 4.5
    if ! grep -q '^# canonical:' "$file"; then
      for k in 1 2 3 4 5 6 9 10 11 12 13 14; do need "color$k" 4.5; done
      need color8 3.0
      if awk -v l="$(luminance "$bg")" 'BEGIN { exit !(l < 0.18) }'; then
        need color7 4.5; need color15 4.5
      else
        need color0 4.5; need color15 4.5
        for k in 1 2 3 4 5 6; do
          local n="color$k" b="color$((k + 8))"
          awk -v x="$(luminance "${!b}")" -v y="$(luminance "${!n}")" 'BEGIN { exit !(x < y) }' ||
            fails+=("$b must be darker than $n on a light theme")
        done
      fi
    fi
    [[ ${#fails[@]} -eq 0 ]] && exit 0
    printf '%s: %s\n' "$(basename "$file")" "${fails[@]}"
    exit 1
  )
}

# theme_fill <template> <out>: replaces {{key}}, {{key_rgb}} and {{name}}
# with the loaded theme. Fails, writing nothing, if a placeholder is left.
theme_fill() {
  local template="$1" out="$2" k script=() tmp
  for k in "${THEME_KEYS[@]}"; do
    script+=(-e "s/{{${k}_rgb}}/$(hex_rgb "${!k}")/g" -e "s/{{${k}}}/${!k}/g")
  done
  script+=(-e "s/{{name}}/${THEME:-theme}/g")
  tmp="$(mktemp)"
  sed "${script[@]}" "$template" > "$tmp"
  if grep -q '{{' "$tmp"; then
    warn "$template: unfilled $(grep -o '{{[^}]*}}' "$tmp" | sort -u | paste -sd' ')"
    rm -f "$tmp"
    return 1
  fi
  mkdir -p "$(dirname "$out")"
  mv "$tmp" "$out"
}

ini_set() {
  local f="$1" section="$2" key="$3" value="$4" tmp
  mkdir -p "$(dirname "$f")"
  touch "$f"
  tmp="$(mktemp)"
  awk -v sec="[$section]" -v key="$key" -v val="$value" '
    function flush() { printf "%s", blank; blank = "" }
    $0 == sec { print; insec = 1; seen = 1; next }
    /^\[/ { if (insec && !done) { print key "=" val; done = 1 } flush(); insec = 0; print; next }
    insec && /^[[:space:]]*$/ { blank = blank $0 "\n"; next }
    insec && index($0, key "=") == 1 { flush(); if (!done) { print key "=" val; done = 1 } next }
    insec { flush(); print; next }
    { print }
    END {
      if (insec && !done) { print key "=" val; done = 1 }
      flush()
      if (!seen) { if (NR) print ""; print sec; print key "=" val }
    }
  ' "$f" > "$tmp" && mv "$tmp" "$f"
}

theme_dark() { awk -v l="$(luminance "$bg")" 'BEGIN { exit !(l < 0.18) }'; }
