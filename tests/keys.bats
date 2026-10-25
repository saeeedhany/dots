#!/usr/bin/env bats

load test_helper

setup() {
  setup_repo_root
  REAL_SUCKLESS="$HOME/gits/suckless"
  setup_fake_home
  export SUCKLESS_DIR="$BATS_TEST_TMPDIR/suckless"
  mkdir -p "$SUCKLESS_DIR/dwm"
  cat > "$SUCKLESS_DIR/dwm/config.def.h" <<'EOF'
static const char *tags[] = { "1", "2", "3", "4" };
static const Layout layouts[] = {
	{ "[]=",      tile },
	{ "><>",      NULL },
	{ "[M]",      monocle },
};
#define MODKEY Mod4Mask
static const Key keys[] = {
	{ MODKEY,                       XK_p,      spawn,          {.v = dmenucmd } },
	{ MODKEY|ShiftMask,             XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	{ MODKEY|ControlMask|ShiftMask, XK_q,      quit,           {1} },
};
EOF
}

teardown() { teardown_fake_home; }

key() { "$REPO_ROOT/bin/keys" | awk -v k="$1" 'BEGIN { FS = "  +" } $1 == k { print $2 }'; }

@test "dwm keys are named and described in words" {
  [ "$(key 'super p')" = "launcher" ]
  [ "$(key 'super shift return')" = "terminal" ]
  [ "$(key 'super j')" = "focus the next window" ]
  [ "$(key 'super h')" = "shrink the master area" ]
  [ "$(key 'super m')" = "monocle layout [M]" ]
  [ "$(key 'super ,')" = "focus the previous monitor" ]
  [ "$(key 'super ctrl shift q')" = "restart dwm" ]
}

@test "tag keys collapse to one line per action, only up to the real tags" {
  [ "$(key 'super 1..4')" = "switch to a tag" ]
  [ "$(key 'super shift 1..4')" = "move the window to a tag" ]
  ! "$REPO_ROOT/bin/keys" | grep -q 'super 5'
}

@test "sxhkd keys come with their comment or their command" {
  [ "$(key 'super c')" = "pick a color anywhere on screen; its hex goes to the clipboard" ]
  [ "$(key 'super shift x')" = "xkill" ]
  [ "$(key 'super /')" = "keys --menu" ]
}

@test "the keyboard switch from xinitrc is listed" {
  [ "$(key 'alt shift')" = "switch keyboard language: us, ara" ]
}

@test "the real dwm config has no binding left undescribed" {
  [ -f "$REAL_SUCKLESS/dwm/config.def.h" ] || skip "no suckless checkout"
  SUCKLESS_DIR="$REAL_SUCKLESS" run "$REPO_ROOT/bin/keys"
  [ "$status" -eq 0 ]
  [[ "$output" != *"{"* && "$output" != *"XK_"* && "$output" != *"Mask"* ]]
}

@test "every key on the home page exists" {
  local dt k left out
  [ -f "$REAL_SUCKLESS/dwm/config.def.h" ] || skip "no suckless checkout"
  out="$(SUCKLESS_DIR="$REAL_SUCKLESS" "$REPO_ROOT/bin/keys" | awk 'BEGIN { FS = "  +" } { print $1 }')"
  while read -r dt; do
    if [[ "$dt" == *" / "* ]]; then
      left="${dt%% / *}"
      set -- "$left" "${left% *} ${dt##* / }"
    else
      set -- "$dt"
    fi
    for k in "$@"; do
      grep -qxF "$k" <<<"$out" || { echo "not a key: $k"; return 1; }
    done
  done < <(sed -n '/class="list keys"/,/<\/dl>/p' "$REPO_ROOT/index.html" | sed -n 's#.*<dt>\(.*\)</dt>.*#\1#p')
}
