#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  setup_fake_home
  mkdir -p "$HOME/.config"
  ln -s "$REPO_ROOT/config/emacs" "$HOME/.config/emacs"
}

teardown() { teardown_fake_home; }

em() {
  emacs --batch -l "$HOME/.config/emacs/early-init.el" \
    --eval "(add-to-list 'custom-theme-load-path \"$HOME/.config/emacs\")" \
    --eval "(when (load dots-palette-file t t) (load-theme 'dots t))" \
    --eval "(princ $1)" 2>/dev/null
}

@test "theme blue: emacs palette names the theme" {
  "$REPO_ROOT/theme" blue >/dev/null
  [ "$(em "(alist-get 'name dots-palette)")" = "blue" ]
}

@test "theme blue: current line number is blue's accent" {
  "$REPO_ROOT/theme" blue >/dev/null
  accent=$(sed -n 's/^accent=//p' "$REPO_ROOT/themes/blue")
  [ "$(em "(face-attribute 'line-number-current-line :foreground)")" = "$accent" ]
}

@test "theme white: emacs background is white's bg" {
  "$REPO_ROOT/theme" white >/dev/null
  bg=$(sed -n 's/^bg=//p' "$REPO_ROOT/themes/white")
  [ "$(em "(face-attribute 'default :background)")" = "$bg" ]
}

@test "the mode line is flat: its box matches its background" {
  "$REPO_ROOT/theme" black >/dev/null
  bg1=$(sed -n 's/^bg1=//p' "$REPO_ROOT/themes/black")
  [ "$(em "(plist-get (face-attribute 'mode-line :box) :color)")" = "$bg1" ]
}

@test "emacs keeps its state out of the repo" {
  [ "$(em 'user-emacs-directory')" = "$HOME/.local/share/emacs/" ]
}

@test "no theme applied yet: emacs starts without a palette" {
  [ "$(em 'dots-palette')" = "nil" ]
}
