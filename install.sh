#!/usr/bin/env bash
# Set up this desktop on an Arch machine, or bring an existing one up to date.
#   git clone https://github.com/saeeedhany/dots && ./dots/install.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
export REPO_ROOT
# shellcheck source=lib/log.sh
. "$REPO_ROOT/lib/log.sh"
# shellcheck source=lib/link.sh
. "$REPO_ROOT/lib/link.sh"
# shellcheck source=lib/pkg.sh
. "$REPO_ROOT/lib/pkg.sh"

# On a fresh machine ~/.local/bin is only added to PATH by bashrc, which has
# not run yet; theme and the linked tools live there.
export PATH="$HOME/.local/bin:$PATH"

STEPS=(check packages aur suckless links wallpapers fonts theme verify)
SUCKLESS_URL="${SUCKLESS_URL:-https://github.com/saeeedhany/suckless}"
SUCKLESS_DIR="${SUCKLESS_DIR:-$(dirname "$REPO_ROOT")/suckless}"
DRY_RUN=0
YES=0
ALL=0
THEME=grey
ONLY=""
SKIP=""

usage() {
  cat <<EOF
usage: ./install.sh [options]
  --theme <name>   theme to apply (default: grey)
  --only a,b       run only these steps
  --skip a,b       run every step except these
  --all            install the full snapshot (packages/all-*.txt) instead of the curated lists
  --dry-run        print what would happen, change nothing
  --yes            don't ask for confirmation
steps: ${STEPS[*]}
EOF
}

# ── steps ──────────────────────────────────────────────────────────────────

step_check() {
  [[ "${FAKE_EUID:-$EUID}" -ne 0 ]] || die "don't run this as root; it uses sudo where needed"
  command -v pacman >/dev/null || die "pacman not found: this setup is for Arch only"
  is_dry_run && return 0
  sudo -v || die "sudo is required"
  curl -fsI --max-time 10 https://archlinux.org >/dev/null || die "no network"
}

step_packages() {
  if [[ "$ALL" -eq 1 ]]; then
    pkg_install_native "$REPO_ROOT/packages/all-native.txt"
  else
    pkg_install_native "$REPO_ROOT/packages/pacman.txt"
  fi
}

step_aur() {
  pkg_ensure_yay
  if [[ "$ALL" -eq 1 ]]; then
    pkg_install_aur "$REPO_ROOT/packages/all-aur.txt"
  else
    pkg_install_aur "$REPO_ROOT/packages/aur.txt"
  fi
}

step_suckless() {
  if [[ -d "$SUCKLESS_DIR/.git" ]] && [[ "$(git -C "$SUCKLESS_DIR" remote get-url origin 2>/dev/null)" == "$SUCKLESS_URL"* ]]; then
    run_cmd "update $SUCKLESS_DIR" git -C "$SUCKLESS_DIR" pull --ff-only
  else
    if [[ -e "$SUCKLESS_DIR" ]]; then
      run_cmd "back up $SUCKLESS_DIR" mv "$SUCKLESS_DIR" "$SUCKLESS_DIR.bak.$(date +%s)"
    fi
    run_cmd "clone $SUCKLESS_URL" git clone "$SUCKLESS_URL" "$SUCKLESS_DIR"
  fi
  run_cmd "install suckless" make -C "$SUCKLESS_DIR" install
}

step_links() { link_all; }

step_wallpapers() {
  run_cmd "mkdir ~/Pictures/Wallpapers" mkdir -p "$HOME/Pictures/Wallpapers"
  run_cmd "copy wallpapers" rsync -a --ignore-existing "$REPO_ROOT/wallpapers/" "$HOME/Pictures/Wallpapers/"
}

step_fonts() { run_cmd "fc-cache" fc-cache -f; }

step_theme() { run_cmd "theme $THEME" "$REPO_ROOT/theme" "$THEME"; }

step_verify() {
  if is_dry_run; then
    printf '[dry-run] verify\n'
    return 0
  fi
  local failures=() line bin
  while read -r line; do
    failures+=("$line")
  done < <(link_check || true)
  for bin in dwm st dmenu dwmblocks theme nvim tmux; do
    command -v "$bin" >/dev/null || failures+=("not on PATH: $bin")
  done
  fc-match '0xProto Nerd Font' 2>/dev/null | grep -q 0xProto || failures+=("font missing: 0xProto Nerd Font")
  [[ -f "$HOME/.config/theme" ]] || failures+=("no theme applied: ~/.config/theme missing")
  if [[ ${#failures[@]} -gt 0 ]]; then
    printf '\nverify failed:\n'
    printf '  %s\n' "${failures[@]}"
    exit 1
  fi
  ok "everything is in place"
}

# ── main ───────────────────────────────────────────────────────────────────

in_list() { [[ ",$2," == *",$1,"* ]]; }

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --theme)   THEME="${2:?--theme needs a name}"; shift ;;
      --only)    ONLY="${2:?--only needs steps}"; shift ;;
      --skip)    SKIP="${2:?--skip needs steps}"; shift ;;
      --all)     ALL=1 ;;
      --dry-run) DRY_RUN=1 ;;
      --yes)     YES=1 ;;
      -h|--help) usage; exit 0 ;;
      *)         usage; exit 2 ;;
    esac
    shift
  done

  local s
  for s in ${ONLY//,/ } ${SKIP//,/ }; do
    in_list "$s" "$(IFS=,; echo "${STEPS[*]}")" || { usage; die "unknown step: $s"; }
  done

  local run=()
  for s in "${STEPS[@]}"; do
    [[ -n "$ONLY" ]] && ! in_list "$s" "$ONLY" && continue
    [[ -n "$SKIP" ]] && in_list "$s" "$SKIP" && continue
    run+=("$s")
  done

  info "steps: ${run[*]}"
  if [[ "$YES" -eq 0 && "$DRY_RUN" -eq 0 ]]; then
    printf 'continue? [y/N] '
    local answer
    read -r answer
    [[ "$answer" =~ ^[Yy]$ ]] || { info "aborted"; exit 0; }
  fi

  for s in "${run[@]}"; do
    printf '\n== %s\n' "$s"
    "step_$s"
  done
  printf '\n'
  ok "done"
}

main "$@"
