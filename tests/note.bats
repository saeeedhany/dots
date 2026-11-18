#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  setup_fake_home
  unset NOTES_DIR
  FAKE="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$FAKE"
  cat > "$FAKE/dmenu" <<DMENU
#!/bin/sh
cat > "$BATS_TEST_TMPDIR/menu"
[ -f "$BATS_TEST_TMPDIR/pick" ] || exit 1
cat "$BATS_TEST_TMPDIR/pick"
DMENU
  cat > "$FAKE/st" <<ST
#!/bin/sh
printf '%s\n' "\$@" > "$BATS_TEST_TMPDIR/st"
ST
  chmod +x "$FAKE/dmenu" "$FAKE/st"
  export PATH="$FAKE:$PATH"
}

teardown() { teardown_fake_home; }

@test "notes are listed newest first, without .md" {
  mkdir -p "$HOME/notes"
  touch -d '2 days ago' "$HOME/notes/old.md"
  touch "$HOME/notes/new.md"
  "$REPO_ROOT/bin/note" || true
  [ "$(cat "$BATS_TEST_TMPDIR/menu")" = "$(printf 'new\nold')" ]
}

@test "picking a note opens it in nvim inside a floating st" {
  mkdir -p "$HOME/notes"
  touch "$HOME/notes/todo.md"
  echo todo > "$BATS_TEST_TMPDIR/pick"
  "$REPO_ROOT/bin/note"
  [ "$(cat "$BATS_TEST_TMPDIR/st")" = "$(printf -- '-c\nnote\n-g\n40x12\n-e\nnvim\n%s' "$HOME/notes/todo.md")" ]
}

@test "the notes folder is created when missing" {
  "$REPO_ROOT/bin/note" || true
  [ -d "$HOME/notes" ]
}

@test "a typed .md name opens that note, not name.md.md" {
  echo todo.md > "$BATS_TEST_TMPDIR/pick"
  "$REPO_ROOT/bin/note"
  [ "$(tail -1 "$BATS_TEST_TMPDIR/st")" = "$HOME/notes/todo.md" ]
}

@test "a name with spaces stays one file" {
  echo "buy milk" > "$BATS_TEST_TMPDIR/pick"
  "$REPO_ROOT/bin/note"
  [ "$(tail -1 "$BATS_TEST_TMPDIR/st")" = "$HOME/notes/buy milk.md" ]
}

@test "names with a slash or a leading dot are refused" {
  for n in "../x" "a/b" ".hidden"; do
    echo "$n" > "$BATS_TEST_TMPDIR/pick"
    run "$REPO_ROOT/bin/note"
    [ "$status" -eq 0 ]
    [ ! -e "$BATS_TEST_TMPDIR/st" ]
  done
}

@test "escape in dmenu opens nothing" {
  run "$REPO_ROOT/bin/note"
  [ "$status" -eq 0 ]
  [ ! -e "$BATS_TEST_TMPDIR/st" ]
}

@test "NOTES_DIR moves the notes folder" {
  export NOTES_DIR="$BATS_TEST_TMPDIR/elsewhere"
  echo a > "$BATS_TEST_TMPDIR/pick"
  "$REPO_ROOT/bin/note"
  [ "$(tail -1 "$BATS_TEST_TMPDIR/st")" = "$NOTES_DIR/a.md" ]
}
