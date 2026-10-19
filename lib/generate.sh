#!/usr/bin/env bash
# Build a whole theme from one background color (theme new).
# All color math runs in awk; sourced after lib/theme.sh.

# shellcheck disable=SC2016 # awk code, not shell
GEN_AWK='
function hexval(s) { return index("0123456789abcdef", tolower(s)) - 1 }
function h2r(hex, c) {
  hex = substr(hex, 2)
  c[1] = hexval(substr(hex, 1, 1)) * 16 + hexval(substr(hex, 2, 1))
  c[2] = hexval(substr(hex, 3, 1)) * 16 + hexval(substr(hex, 4, 1))
  c[3] = hexval(substr(hex, 5, 1)) * 16 + hexval(substr(hex, 6, 1))
}
function clamp(x, lo, hi) { return x < lo ? lo : (x > hi ? hi : x) }
function r2h(r, g, b) {
  return sprintf("#%02x%02x%02x", clamp(int(r + 0.5), 0, 255), clamp(int(g + 0.5), 0, 255), clamp(int(b + 0.5), 0, 255))
}
function hsl(hex, o,   c, r, g, b, mx, mn, d) {
  h2r(hex, c); r = c[1] / 255; g = c[2] / 255; b = c[3] / 255
  mx = r > g ? (r > b ? r : b) : (g > b ? g : b)
  mn = r < g ? (r < b ? r : b) : (g < b ? g : b)
  o["l"] = (mx + mn) / 2; d = mx - mn
  if (d == 0) { o["h"] = 0; o["s"] = 0; return }
  o["s"] = o["l"] > 0.5 ? d / (2 - mx - mn) : d / (mx + mn)
  if (mx == r) o["h"] = (g - b) / d + (g < b ? 6 : 0)
  else if (mx == g) o["h"] = (b - r) / d + 2
  else o["h"] = (r - g) / d + 4
  o["h"] = o["h"] * 60
}
function hue2(p, q, t) {
  if (t < 0) t += 1; if (t > 1) t -= 1
  if (t < 1 / 6) return p + (q - p) * 6 * t
  if (t < 1 / 2) return q
  if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6
  return p
}
function hslhex(h, s, l,   q, p) {
  l = clamp(l, 0, 1); s = clamp(s, 0, 1)
  h = h - 360 * int(h / 360); if (h < 0) h += 360
  if (s == 0) return r2h(l * 255, l * 255, l * 255)
  q = l < 0.5 ? l * (1 + s) : l + s - l * s; p = 2 * l - q
  return r2h(hue2(p, q, h / 360 + 1 / 3) * 255, hue2(p, q, h / 360) * 255, hue2(p, q, h / 360 - 1 / 3) * 255)
}
function lin(x) { x /= 255; return x <= 0.04045 ? x / 12.92 : ((x + 0.055) / 1.055) ^ 2.4 }
function lum(hex, c) { h2r(hex, c); return 0.2126 * lin(c[1]) + 0.7152 * lin(c[2]) + 0.0722 * lin(c[3]) }
function cr(a, b,   x, y, t) { x = lum(a); y = lum(b); if (x < y) { t = x; x = y; y = t }; return (x + 0.05) / (y + 0.05) }
function mixh(a, b, p,   x, y) { h2r(a, x); h2r(b, y); p /= 100
  return r2h(x[1] + (y[1] - x[1]) * p, x[2] + (y[2] - x[2]) * p, x[3] + (y[3] - x[3]) * p) }
function isdark(bg) { return lum(bg) < 0.18 }
# fix: move lightness away from bg in 0.02 steps until contrast >= min
function fix(c, bg, min,   o, step) {
  hsl(c, o); step = isdark(bg) ? 0.02 : -0.02
  while (cr(c, bg) < min && o["l"] >= 0 && o["l"] <= 1) { o["l"] += step; c = hslhex(o["h"], o["s"], o["l"]) }
  return c
}
function shift(c, d,   o) { hsl(c, o); return hslhex(o["h"], o["s"], o["l"] + d) }
# neutral: no real hue. Uses HSV saturation (chroma / max), which reads
# near-white and near-black tints the way people name them.
function neutral(c,   x, mx, mn) {
  h2r(c, x)
  mx = x[1] > x[2] ? (x[1] > x[3] ? x[1] : x[3]) : (x[2] > x[3] ? x[2] : x[3])
  mn = x[1] < x[2] ? (x[1] < x[3] ? x[1] : x[3]) : (x[2] < x[3] ? x[2] : x[3])
  return mx == 0 || (mx - mn) / mx < 0.08
}
# name: the plain color word
function name(c,   o, h) {
  hsl(c, o); h = o["h"]
  if (neutral(c)) return o["l"] < 0.12 ? "black" : (o["l"] > 0.80 ? "white" : "grey")
  if (h >= 15 && h < 45 && o["l"] < 0.35) return "brown"
  if (h < 15 || h >= 345) return "red"
  if (h < 40) return "orange"
  if (h < 65) return "yellow"
  if (h < 165) return "green"
  if (h < 195) return "cyan"
  if (h < 255) return "blue"
  if (h < 290) return "purple"
  return "pink"
}
'

gen_awk() { awk "$GEN_AWK $1"; }

# hex_hsl <#hex>: "h s l"
hex_hsl() { gen_awk "BEGIN { hsl(\"$1\", o); printf \"%.3f %.3f %.3f\", o[\"h\"], o[\"s\"], o[\"l\"] }"; }

# hsl_hex <h> <s> <l>
hsl_hex() { gen_awk "BEGIN { print hslhex($1, $2, $3) }"; }

# mix <#a> <#b> <pct>: pct% of b blended into a
mix() { gen_awk "BEGIN { print mixh(\"$1\", \"$2\", $3) }"; }

# fix_contrast <#c> <#bg> <min>
fix_contrast() { gen_awk "BEGIN { print fix(\"$1\", \"$2\", $3) }"; }

color_name() { gen_awk "BEGIN { print name(\"$1\") }"; }

# normalize_color <input>: #rrggbb from #rrggbb, rrggbb, #rgb or rgb
normalize_color() {
  local c="${1#\#}"
  c="${c,,}"
  [[ "$c" =~ ^[0-9a-f]{3}$ ]] && c="${c:0:1}${c:0:1}${c:1:1}${c:1:1}${c:2:1}${c:2:1}"
  [[ "$c" =~ ^[0-9a-f]{6}$ ]] || return 1
  printf '#%s' "$c"
}

# generate_theme <#bg>: prints a complete theme file
generate_theme() {
  gen_awk "BEGIN {
    bg = \"$1\"; hsl(bg, B); dark = isdark(bg); sg = dark ? 1 : -1
    t[\"bg\"] = bg
    t[\"bg1\"] = shift(bg, sg * 0.015); t[\"bg2\"] = shift(bg, sg * 0.03); t[\"bg3\"] = shift(bg, sg * 0.05)
    t[\"line\"] = shift(bg, sg * 0.15); t[\"line2\"] = shift(bg, sg * 0.20)
    fs = B[\"s\"] < 0.15 ? B[\"s\"] : 0.15
    split(dark ? \"0.85 0.62 0.50 0.42\" : \"0.22 0.38 0.48 0.55\", fl, \" \")
    t[\"fg\"] = fix(hslhex(B[\"h\"], fs, fl[1]), bg, 4.5)
    t[\"fg1\"] = fix(hslhex(B[\"h\"], fs, fl[2]), bg, 4.5)
    t[\"fg2\"] = fix(hslhex(B[\"h\"], fs, fl[3]), bg, 3.0)
    t[\"fg3\"] = hslhex(B[\"h\"], fs, fl[4])
    S = clamp(B[\"s\"] * 0.5 + 0.25, 0.25, 0.55); L = dark ? 0.62 : 0.38; LB = L + sg * 0.08
    split(\"0 95 40 210 320 175\", hues, \" \")
    for (i = 1; i <= 6; i++) {
      n = fix(hslhex(hues[i], S, L), bg, 4.5)
      b = fix(hslhex(hues[i], S, LB), bg, 4.5)
      if (!dark) { hsl(b, o); while (lum(b) >= lum(n) && o[\"l\"] > 0) { o[\"l\"] -= 0.02; b = hslhex(o[\"h\"], o[\"s\"], o[\"l\"]) } }
      t[\"color\" i] = n; t[\"color\" (i + 8)] = b
    }
    if (dark) {
      t[\"color0\"] = t[\"bg3\"]; t[\"color7\"] = fix(t[\"fg\"], bg, 4.5); t[\"color8\"] = t[\"fg2\"]
      hsl(t[\"fg\"], o); t[\"color15\"] = fix(hslhex(o[\"h\"], o[\"s\"], 0.92), bg, 4.5)
    } else {
      t[\"color0\"] = fix(t[\"fg\"], bg, 4.5); t[\"color7\"] = t[\"fg1\"]; t[\"color8\"] = t[\"fg2\"]
      hsl(t[\"fg\"], o); t[\"color15\"] = fix(hslhex(o[\"h\"], o[\"s\"], 0.12), bg, 4.5)
    }
    ah = neutral(bg) ? 38 : B[\"h\"] + 180
    a = fix(hslhex(ah, S, L), bg, 4.5); t[\"accent\"] = a
    t[\"accent_light1\"] = shift(a, sg * 0.06); t[\"accent_light2\"] = shift(a, sg * 0.11)
    t[\"accent_dark1\"] = mixh(a, bg, 20); t[\"accent_dark2\"] = mixh(a, bg, 35)
    t[\"accent_dark3\"] = mixh(a, bg, 50); t[\"accent_dark4\"] = mixh(a, bg, 62)
    t[\"green\"] = t[\"color2\"]; t[\"green_light\"] = t[\"color10\"]
    t[\"red\"] = t[\"color1\"]; t[\"red_dark\"] = mixh(t[\"color1\"], bg, 20)
    t[\"blue\"] = t[\"color4\"]; t[\"cursor\"] = a
    n = split(\"${THEME_KEYS[*]}\", keys, \" \")
    for (i = 1; i <= n; i++) printf \"%s=%s\\n\", keys[i], t[keys[i]]
  }"
}
