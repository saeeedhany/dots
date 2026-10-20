# dots

My Arch Linux (btw) desktop: dwm, st, dmenu, tmux, neovim, bash, and one flat
color across the whole screen. One command sets it all up on a new machine,
and one command repaints everything in another color.

## Install

On a fresh Arch install, as your normal user:

```
git clone https://github.com/saeeedhany/dots
./dots/install.sh
```

It shows the steps and asks once, then runs them in order:

| Step | What it does |
|---|---|
| check | Arch, not root, sudo, network |
| packages | `packages/pacman.txt` through pacman |
| aur | yay if missing, then `packages/aur.txt` |
| suckless | clones [suckless](https://github.com/saeeedhany/suckless) to `~/.config/suckless`, builds and installs dwm, st, dmenu, dwmblocks |
| links | symlinks every config into place (anything already there is moved to `<name>.bak.<time>`) |
| wallpapers | copies `wallpapers/` to `~/Pictures/Wallpapers` |
| fonts | `fc-cache` |
| theme | applies `grey` (or `--theme <name>`) |
| verify | checks every link, binary and font, and fails loudly if anything is missing |

Options:

```
./install.sh --dry-run          show every step, change nothing
./install.sh --only links,theme run just these steps
./install.sh --skip packages    run everything else
./install.sh --theme black      start in another theme
./install.sh --all              install the full package snapshot instead of the curated lists
./install.sh --yes              don't ask
```

Running it again is safe: steps that are already done change nothing.

## Themes

A theme is one flat background color plus matching text, accent and a full
16 color terminal palette. Switching repaints the wallpaper, the dwm bar, st,
dmenu, tmux, the prompt, dunst, zathura, neovim, Vesktop and Firefox.

```
theme                 list themes, * marks the current one
theme black           switch the whole machine to black
theme new 2b2f2a      build a theme from one color, save it, switch to it
theme new 2b2f2a moss same, with your own name
```

| Theme | Background | Look |
|---|---|---|
| grey | `#282828` | Onyx: cream text, gold accent (default) |
| gruvbox | `#1d2021` | gruvbox dark, hard |
| black | `#161717` | near black, muted |
| blue | `#1b1f27` | cool dark slate |
| white | `#e8e6e1` | soft warm off-white |

Open terminals, the bar and running neovim recolor right away. Firefox picks
the new colors up the next time it starts.

### Making a theme by hand

Copy a file in `themes/` and change the colors. Every line is `key=#rrggbb`:

- `bg bg1 bg2 bg3`: background and three steps up for raised surfaces
- `line line2`: borders and separators
- `fg fg1 fg2 fg3`: text, dim text, muted text, disabled text
- `accent accent_light1 accent_light2 accent_dark1..4`: the one highlight color and its shades
- `green green_light red red_dark blue cursor`
- `color0` to `color15`: the terminal palette

`theme <name>` refuses a file with a missing key or text that is hard to read
on its background, and tells you which line.

## Layout

```
install.sh      set up a machine
theme           switch themes (linked to ~/.local/bin/theme)
sync.sh         compare installed packages with the snapshot
config/         each folder is linked to ~/.config/<name>
home/           each file is linked to ~/.<name>
bin/            linked to ~/.local/bin
themes/         one file per theme
templates/      Vesktop and Firefox styles, filled in from the theme
packages/       curated lists and the full snapshot
wallpapers/     copied to ~/Pictures/Wallpapers
manuals/        bash and tmux guides
lib/            what install.sh and theme are built from
tests/          bats tests, and a clean-machine test in docker
```

Configs are links, so editing `~/.config/nvim` or `~/.bashrc` edits this
repo. Commit and push as usual.

## Per machine

Anything only one machine needs goes in `~/.config/local.sh`. `.xinitrc`
sources it at login and it is never committed. The second monitor setup in
`.xinitrc` only runs when that monitor is plugged in.

## Keeping the package list current

```
./sync.sh           what was installed or removed since the snapshot
./sync.sh --apply   rewrite the snapshot from this machine
```

## Guides

- [Bash](manuals/bash.md)
- [tmux](manuals/tmux.md)

## Tests

```
bats tests/             unit and integration tests (needs bats, jq, imagemagick)
tests/docker/run.sh     full install on a clean Arch container
```
