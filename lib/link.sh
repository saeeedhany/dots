#!/usr/bin/env bash
# Where every repo file lives on the machine. Used by install and verify.
# Sourced after lib/log.sh; needs REPO_ROOT.

# link_map: prints "repo_rel<TAB>target" lines
link_map() {
  local p name
  for p in "$REPO_ROOT"/config/*/; do
    name="$(basename "$p")"
    printf 'config/%s\t%s\n' "$name" "$HOME/.config/$name"
  done
  for p in "$REPO_ROOT"/home/*; do
    name="$(basename "$p")"
    printf 'home/%s\t%s\n' "$name" "$HOME/.$name"
  done
  for p in "$REPO_ROOT"/bin/*; do
    [[ -f "$p" ]] || continue
    name="$(basename "$p")"
    printf 'bin/%s\t%s\n' "$name" "$HOME/.local/bin/$name"
  done
  printf 'theme\t%s\n' "$HOME/.local/bin/theme"
}

# link_one <src_abs> <target>: make target a symlink to src, backing up
# whatever else is there to <target>.bak.<ts>
link_one() {
  local src="$1" target="$2"
  if [[ -L "$target" && "$(readlink "$target")" == "$src" ]]; then
    return 0
  fi
  run_cmd "mkdir $(dirname "$target")" mkdir -p "$(dirname "$target")"
  if [[ -e "$target" || -L "$target" ]]; then
    local bak
    bak="$target.bak.$(date +%s)"
    run_cmd "back up $target -> $bak" mv "$target" "$bak"
  fi
  run_cmd "link $target -> $src" ln -s "$src" "$target"
}

link_all() {
  local rel target
  while IFS=$'\t' read -r rel target; do
    link_one "$REPO_ROOT/$rel" "$target"
  done < <(link_map)
}

# link_check: prints each missing or wrong target, returns 1 if any
link_check() {
  local rel target bad=0
  while IFS=$'\t' read -r rel target; do
    if [[ ! -L "$target" || "$(readlink "$target")" != "$REPO_ROOT/$rel" || ! -e "$target" ]]; then
      printf 'not linked: %s\n' "$target"
      bad=1
    fi
  done < <(link_map)
  return "$bad"
}
