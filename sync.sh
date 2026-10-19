#!/usr/bin/env bash
# Compare installed packages with packages/all.txt.
#   ./sync.sh           show what changed since the snapshot
#   ./sync.sh --apply   rewrite the snapshot from this machine
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
ALL="${PACKAGES_ALL:-$REPO_ROOT/packages/all.txt}"

installed="$(pacman -Qqe | sort)"
snapshot="$(sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$ALL" | sort)"

comm -13 <(printf '%s\n' "$snapshot") <(printf '%s\n' "$installed") | sed 's/^/+ /'
comm -23 <(printf '%s\n' "$snapshot") <(printf '%s\n' "$installed") | sed 's/^/- /'

if [[ "${1:-}" == "--apply" ]]; then
  {
    echo "# Every explicitly installed package on the origin machine."
    echo "# Regenerate with ./sync.sh --apply. Used by ./install.sh --all"
    echo
    printf '%s\n' "$installed"
  } > "$ALL"
  echo "updated $ALL"
fi
