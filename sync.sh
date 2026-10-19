#!/usr/bin/env bash
# Compare installed packages with the snapshots in packages/.
#   ./sync.sh           show what changed since the snapshots
#   ./sync.sh --apply   rewrite the snapshots from this machine
# Native and AUR packages are kept apart so ./install.sh --all can send each
# list to the right installer on a machine that has neither yet.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
DIR="${PACKAGES_DIR:-$REPO_ROOT/packages}"

# compare <snapshot file> <installed list>
compare() {
  local snapshot=""
  # a snapshot that does not exist yet counts as empty
  [[ -f "$1" ]] && snapshot="$(sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$1" | sort)"
  comm -13 <(printf '%s\n' "$snapshot") <(printf '%s\n' "$2") | sed 's/^/+ /'
  comm -23 <(printf '%s\n' "$snapshot") <(printf '%s\n' "$2") | sed 's/^/- /'
}

# write <file> <what> <list>
write() {
  {
    echo "# Every explicitly installed $2 package on the origin machine."
    echo "# Regenerate with ./sync.sh --apply. Used by ./install.sh --all"
    echo
    printf '%s\n' "$3"
  } > "$1"
  echo "updated $1"
}

native="$(pacman -Qqen | sort)"
aur="$(pacman -Qqem | sort)"

compare "$DIR/all-native.txt" "$native"
compare "$DIR/all-aur.txt" "$aur"

if [[ "${1:-}" == "--apply" ]]; then
  write "$DIR/all-native.txt" native "$native"
  write "$DIR/all-aur.txt" AUR "$aur"
fi
