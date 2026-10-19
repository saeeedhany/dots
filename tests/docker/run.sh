#!/usr/bin/env bash
# Install dots on a clean Arch container and check the result.
#   tests/docker/run.sh [path-to-suckless-repo]
# The suckless repo is copied in and used as SUCKLESS_URL, so this tests the
# local code without needing it pushed.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../.." && pwd)"
SUCKLESS="${1:-$HOME/gits/suckless}"
CTX="$(mktemp -d)"
trap 'rm -rf "$CTX"' EXIT

rsync -a --exclude=.remember --exclude=.superpowers --exclude=docs "$REPO_ROOT/" "$CTX/dots/"
rsync -a "$SUCKLESS/" "$CTX/suckless/"
cp "$REPO_ROOT/tests/docker/Dockerfile" "$CTX/"
cp /etc/pacman.d/mirrorlist "$CTX/mirrorlist"
docker build --network host -q -t dots-clean-machine "$CTX" >/dev/null

docker run --rm --network host dots-clean-machine bash -c '
  set -euo pipefail
  export SUCKLESS_URL=/home/tester/suckless-src
  ./dots/install.sh --yes --skip aur
  ./dots/install.sh --only verify
  ~/.local/bin/theme white
  for f in ~/.cache/theme/Xresources ~/Pictures/Wallpapers/white.png \
           ~/.config/vesktop/themes/white.theme.css ~/.config/theme; do
    [ -e "$f" ] || { echo "missing: $f"; exit 1; }
  done
  [ "$(cat ~/.config/theme)" = white ]
  echo "CLEAN MACHINE: PASS"
'
