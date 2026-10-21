# bash

The shell is three small files, each with one job:

1. `home/bash_profile` runs once at login. It sets the environment (PATH, editor, pager, nnn) and starts X on tty1.
2. `home/bashrc` runs in every interactive shell. It sets the prompt, colors, history, `z`, aliases and functions.
3. `home/inputrc` configures readline, so vi mode and the completion keys also work in every program that uses readline.

Anything only one machine needs goes in `~/.config/local.bash`, which `bashrc` loads last and which is never committed.

## prompt

```
~/gits/dots main ❯
```

The directory, the git branch when you are in a repository, then `❯`. The colors come from the current theme, so `theme <name>` changes them in every new shell.

## moving around

`z <text>` jumps to the most recent folder you visited whose path contains the text. `z` alone goes home.

`zi [text]` lists those folders with how long ago you were there, newest first, and jumps to the one you pick.

Every folder you enter is remembered in `~/.z_data`, the last 1000 of them. Home and `/` are not.

`..`, `...` and `....` go up one, two or three folders. `c` is `cd`, and `mkcd <dir>` creates a folder and enters it.

## fzf

1. `Ctrl+R` searches your command history and puts the pick on the prompt.
2. `Ctrl+T` lists files and folders below where you are and pastes the pick at the cursor.
3. `Alt+C` lists folders below where you are and enters the pick.
4. `**` then `Tab` opens fzf for the command you are typing: `nvim **<Tab>`, `cd **<Tab>`, `kill **<Tab>`.
5. `fe` lists files with a preview and opens the pick in nvim.
6. `rg_fzf <text>` lists files that contain the text, previews the matching lines, and opens the pick in nvim.

Files come from `fd`, hidden files included, `.git` skipped. Colors come from the theme.

## keys

The shell starts in vi insert mode. `Esc` switches to normal mode, where `k` and `j` walk through history and the usual vi motions work.

1. `Tab` cycles through completions, `Shift+Tab` goes back.
2. `Up` and `Down` search history for commands that start with what you already typed.
3. `Home`, `End`, `Delete` and `Ctrl+Left` or `Ctrl+Right` work as expected.

Completion ignores case.

## history

50000 commands are kept, with their dates. Duplicates and commands that start with a space are not saved. Every shell writes and rereads history after each command, so all open terminals share it.

## aliases

Files: `ls` is the long listing, `la` adds hidden files, `l` is the short grid. `tree`, `grep`, `diff` and `ip` are colored. `cat` is bat without decoration or paging. `df`, `du` and `free` print human sizes.

Git: `gs` status, `ga` add, `gc` commit, `gp` push, `gl` log graph, `gd` diff, `gco` checkout, `gb` branch.

Packages: `u` updates the system, `i` installs, `remove` removes with dependencies, `search` searches, `orphans` removes packages nothing needs anymore.

Other: `v` nvim, `n` nnn, `e` exit, `open` opens with the default program, `f <image>` sets a wallpaper, `ports` lists listening ports, `watch` keeps colors.

## functions

`extract <file>` unpacks tar, zip, 7z, rar, iso, gz, bz2, xz, zst and Z files.

`ducks [n]` shows the n biggest entries in the current folder, 10 by default.
