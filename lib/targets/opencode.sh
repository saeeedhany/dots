#!/usr/bin/env bash

render_opencode() {
  local dir="$HOME/.config/opencode" tui tmp
  mkdir -p "$dir/themes"
  jq -n \
    --arg bg "$bg" --arg bg1 "$bg1" --arg bg2 "$bg2" --arg bg3 "$bg3" \
    --arg line "$line" --arg line2 "$line2" \
    --arg fg "$fg" --arg fg1 "$fg1" --arg fg2 "$fg2" --arg fg3 "$fg3" \
    --arg accent "$accent" --arg accent_light "$accent_light1" \
    --arg green "$green" --arg red "$red" --arg blue "$blue" \
    --arg magenta "$color5" --arg cyan "$color6" --arg yellow "$color3" \
    --arg add_bg "$(mix "$bg" "$green" 15)" --arg del_bg "$(mix "$bg" "$red" 15)" \
    --arg add_ln "$(mix "$bg" "$green" 8)" --arg del_ln "$(mix "$bg" "$red" 8)" '
  {
    "$schema": "https://opencode.ai/theme.json",
    theme: {
      primary: $accent, secondary: $blue, accent: $accent,
      error: $red, warning: $yellow, success: $green, info: $blue,
      text: $fg, textMuted: $fg2,
      background: $bg, backgroundPanel: $bg1, backgroundElement: $bg2, backgroundMenu: $bg1,
      border: $line, borderActive: $fg2, borderSubtle: $line,
      selectedListItemText: $bg,
      diffAdded: $green, diffRemoved: $red, diffContext: $fg2, diffHunkHeader: $fg2,
      diffHighlightAdded: $green, diffHighlightRemoved: $red,
      diffAddedBg: $add_bg, diffRemovedBg: $del_bg, diffContextBg: $bg1,
      diffLineNumber: $fg3, diffAddedLineNumberBg: $add_ln, diffRemovedLineNumberBg: $del_ln,
      markdownText: $fg, markdownHeading: $accent, markdownLink: $blue, markdownLinkText: $accent_light,
      markdownCode: $green, markdownBlockQuote: $fg2, markdownEmph: $yellow, markdownStrong: $fg,
      markdownHorizontalRule: $line2, markdownListItem: $accent, markdownListEnumeration: $accent,
      markdownImage: $blue, markdownImageText: $accent_light, markdownCodeBlock: $fg,
      syntaxComment: $fg3, syntaxKeyword: $red, syntaxFunction: $accent, syntaxVariable: $fg,
      syntaxString: $green, syntaxNumber: $magenta, syntaxType: $cyan, syntaxOperator: $fg1,
      syntaxPunctuation: $fg1
    }
  }' > "$dir/themes/dots.json"
  tui="$dir/tui.json"
  [[ -f "$tui" ]] || printf '{"$schema": "https://opencode.ai/tui.json"}\n' > "$tui"
  tmp="$(mktemp)"
  if jq '.theme = "dots"' "$tui" > "$tmp" 2>/dev/null; then
    mv "$tmp" "$tui"
  else
    rm -f "$tmp"
    warn "opencode: $tui is not valid JSON; pick the dots theme with /theme"
  fi
}

reload_opencode() {
  pgrep -x opencode >/dev/null || return 0
  info "opencode: restart it to see the new theme"
}
