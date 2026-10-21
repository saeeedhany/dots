#!/usr/bin/env bash
# userChrome.css and userContent.css in every Firefox profile.
# Firefox reads them at start, so a running Firefox needs a restart.

FIREFOX_PREF='user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'

# firefox_profiles: absolute path of every profile: those in profiles.ini
# plus any folder with a prefs.js (profile groups are not listed there)
firefox_profiles() {
  local root p
  {
    for root in "$HOME/.mozilla/firefox" "$HOME/.config/zen" "$HOME/.zen"; do
      if [[ -f "$root/profiles.ini" ]]; then
        awk -F= -v root="$root" '
          /^\[/ { if (path != "") print (rel ? root "/" path : path); path = ""; rel = 1; next }
          $1 == "Path" { path = substr($0, 6) }
          $1 == "IsRelative" { rel = ($2 == 1) }
          END { if (path != "") print (rel ? root "/" path : path) }
        ' "$root/profiles.ini"
      fi
      for p in "$root"/*/prefs.js; do
        [[ -f "$p" ]] && dirname "$p"
      done
    done
  } | awk '!seen[$0]++'
}

render_firefox() {
  local p
  while read -r p; do
    [[ -d "$p" ]] || continue
    theme_fill "$REPO_ROOT/templates/userChrome.css" "$p/chrome/userChrome.css"
    theme_fill "$REPO_ROOT/templates/userContent.css" "$p/chrome/userContent.css"
    grep -qxF "$FIREFOX_PREF" "$p/user.js" 2>/dev/null || printf '%s\n' "$FIREFOX_PREF" >> "$p/user.js"
  done < <(firefox_profiles)
}

reload_firefox() {
  if [[ -z "$(firefox_profiles)" ]]; then
    info "firefox: no profile yet; the theme applies after its first launch and your next login"
  elif pgrep -x firefox >/dev/null || pgrep -x zen >/dev/null || pgrep -x zen-bin >/dev/null; then
    info "firefox: restart it, and zen, to see the new theme"
  fi
}
