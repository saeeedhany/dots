#!/usr/bin/env bash
# Package installation. Sourced after lib/log.sh.

# pkg_list <file>: package names without comments or blank lines
pkg_list() {
  sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$1" | grep -v '^$' || true
}

pkg_install_native() {
  local pkgs
  mapfile -t pkgs < <(pkg_list "$1")
  [[ ${#pkgs[@]} -gt 0 ]] || return 0
  run_cmd "pacman -S ${pkgs[*]}" sudo pacman -S --needed --noconfirm "${pkgs[@]}"
}

pkg_ensure_yay() {
  command -v yay >/dev/null && return 0
  local dir
  dir="$(mktemp -d)"
  run_cmd "build yay from the AUR" bash -c \
    "git clone --depth=1 https://aur.archlinux.org/yay-bin.git '$dir/yay' && cd '$dir/yay' && makepkg -si --noconfirm"
  rm -rf "$dir"
}

pkg_install_aur() {
  local pkgs
  mapfile -t pkgs < <(pkg_list "$1")
  [[ ${#pkgs[@]} -gt 0 ]] || return 0
  run_cmd "yay -S ${pkgs[*]}" yay -S --needed --noconfirm "${pkgs[@]}"
}
