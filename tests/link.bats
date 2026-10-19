#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  setup_fake_home
  # Work on a copy so the test controls exactly what exists.
  local copy="$BATS_TEST_TMPDIR/repo"
  rsync -a --exclude=.git --exclude=wallpapers --exclude=.remember --exclude=.superpowers --exclude=docs "$REPO_ROOT/" "$copy/"
  [ -e "$copy/theme" ] || { printf '#!/usr/bin/env bash\n' > "$copy/theme"; chmod +x "$copy/theme"; }
  REPO_ROOT="$copy"
  DRY_RUN=0
  source "$REPO_ROOT/lib/log.sh"
  source "$REPO_ROOT/lib/link.sh"
}

teardown() { teardown_fake_home; }

@test "link_map covers config, home, bin, study and theme" {
  run link_map
  [ "$status" -eq 0 ]
  [[ "$output" == *$'config/nvim\t'"$HOME/.config/nvim"* ]]
  [[ "$output" == *$'home/bashrc\t'"$HOME/.bashrc"* ]]
  [[ "$output" == *$'bin/deasy\t'"$HOME/.local/bin/deasy"* ]]
  [[ "$output" == *$'bin/study/bin/study\t'"$HOME/.local/bin/study"* ]]
  [[ "$output" == *$'theme\t'"$HOME/.local/bin/theme"* ]]
  printf '%s\n' "$output" | grep -q $'^bin/study\t' && return 1; true
}

@test "link_all links every target to its repo path" {
  link_all
  while IFS=$'\t' read -r rel target; do
    [ -L "$target" ] || { echo "not a link: $target"; return 1; }
    [ "$(readlink "$target")" = "$REPO_ROOT/$rel" ] || { echo "wrong: $target"; return 1; }
  done < <(link_map)
}

@test "an existing regular file is backed up with its content" {
  echo "old bashrc" > "$HOME/.bashrc"
  link_all
  bak=$(ls "$HOME"/.bashrc.bak.*)
  [ "$(cat "$bak")" = "old bashrc" ]
  [ -L "$HOME/.bashrc" ]
}

@test "an existing directory is backed up whole" {
  mkdir -p "$HOME/.config/nvim" && echo x > "$HOME/.config/nvim/init.lua"
  link_all
  [ -f "$(ls -d "$HOME"/.config/nvim.bak.*)/init.lua" ]
}

@test "a second run makes no backups" {
  link_all
  link_all
  run bash -c "find '$HOME' -name '*.bak.*' | wc -l"
  [ "$output" -eq 0 ]
}

@test "DRY_RUN=1 creates nothing" {
  DRY_RUN=1 link_all
  [ ! -e "$HOME/.bashrc" ]
  [ ! -e "$HOME/.config/nvim" ]
}

@test "link_check passes after link_all and fails after a link is removed" {
  link_all
  link_check
  rm "$HOME/.bashrc"
  run link_check
  [ "$status" -eq 1 ]
  [[ "$output" == *".bashrc"* ]]
}
