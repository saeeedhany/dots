# dots

**dots** is a curated collection of configuration files and daily-use tools that power my Arch Linux (btw) environment.

This repository reflects a systems-oriented, minimalist workflow focused on efficiency, clarity, and full control over the development environment.

## Install

On a fresh Arch machine, as your normal user:

```
git clone https://github.com/saeeedhany/dots
./dots/install.sh
```

One command sets up everything: packages, the **[suckless](https://github.com/saeeedhany/suckless)** tools built from source, every config linked into place, wallpapers, fonts and a theme. It finishes by checking that everything landed, and tells you exactly what is missing if something did not.

Anything already on the machine is kept as `<name>.bak.<time>`, and running it again is safe.

```
./install.sh --dry-run          show every step, change nothing
./install.sh --only links,theme run just these steps
./install.sh --skip packages    run everything else
./install.sh --theme black      start in another theme
./install.sh --all              install every package from the origin machine
```

## Included Configurations

This repository contains configuration files for the following tools:

- **[Bash](home/bashrc)**
  Shell customizations and workflow enhancements ([guide](manuals/bash.md))

- **[Neovim](config/nvim)**
  A carefully tuned editor setup focused on speed, extensibility, and keyboard-driven workflows

- **[Emacs](config/emacs)**
  Plain Emacs: built in tools first, a few packages for git, notes, web and LaTeX, and the machine's theme

- **[Tmux](config/tmux)**
  Terminal multiplexing optimized for long-running sessions and parallel tasks ([guide](manuals/tmux.md))

- **[Zathura](config/zathura)**
  A minimal, keyboard-centric document viewer

- **[Dunst](config/dunst)**
  Lightweight notification daemon

- **[sxhkd](config/sxhkd)**
  Simple X hotkey daemon for keyboard shortcuts

- **[dwmblocks](config/dwmblocks/scripts)**
  The scripts behind the status bar

The design system behind the colors is explained on [dots.saeed.cool/design](https://dots.saeed.cool/design.html), and the reasons behind each setup in the [blog](https://dots.saeed.cool/blog/).

Configs are linked, not copied: editing `~/.config/nvim` or `~/.bashrc` edits this repo.

## X Server Configuration

X-related startup and environment configuration scripts:

- **[home](home)**
  - `xinitrc`
  - `bash_profile`
  - `inputrc`

These files define session startup behavior, environment variables, and display initialization.

Anything only one machine needs goes in `~/.config/local.sh`, which `xinitrc` loads at login, or in `~/.config/local.bash`, which every shell loads. Neither is ever committed.

> [!NOTE]
> If you use **X11 (X Server)**, you will likely need the **[picom](config/picom)** configuration.

## Aesthetics & Visual Consistency

While functionality comes first, visual consistency still matters:

- One flat color across the whole screen. The wallpaper, the dwm bar and the terminal share the same background.
- **[Themes](themes)** that repaint everything at once: wallpaper, dwm, st, dmenu, tmux, the prompt, fzf, ls, dunst, zathura, neovim, opencode, btop, rmpc, GTK and Qt apps, GIMP, Kdenlive, OBS, Vesktop, Firefox and Zen. Terminal programs like htop, nnn, ranger, vifm and cava follow st's colors on their own.
  - `grey` the Onyx look, cream text and a gold accent (default)
  - `gruvbox` gruvbox dark, hard
  - `black` near black and muted
  - `blue` cool dark slate
  - `white` soft warm off-white
- A collection of curated **[Wallpapers](wallpapers)**

```
theme                 list themes, * marks the current one
theme black           switch the whole machine
theme new 2b2f2a      build a whole theme from one color and switch to it
theme new 2b2f2a moss same, with your own name
```

To make one by hand, copy a file in `themes/` and change its colors. `theme` refuses a theme with a missing color or text that is hard to read, and says which line.
