# The Most Handsome Bash Configuration - User Manual

---

## Table of Contents

1. [Installation](#installation)
2. [Core Features](#core-features)
3. [Navigation](#navigation)
4. [History & Search](#history--search)
5. [Aliases Reference](#aliases-reference)
6. [Custom Functions](#custom-functions)
7. [Keyboard Shortcuts](#keyboard-shortcuts)
8. [Common Misconceptions](#common-misconceptions)
9. [Troubleshooting](#troubleshooting)
10. [Customization](#customization)

---

## Installation

### Quick Setup

```bash
# Backup existing configuration
cp ~/.bashrc ~/.bashrc.backup

# Install new configuration
cp .bashrc ~/.bashrc

# Reload
source ~/.bashrc
```

### Required Dependencies

```bash
# Arch Linux
sudo pacman -S fzf bat ripgrep fd

# Ubuntu/Debian
sudo apt install fzf bat ripgrep fd-find
```

| Tool | Purpose | Required |
|------|---------|----------|
| fzf | Fuzzy finder for history/files | Yes |
| bat | Enhanced cat with syntax highlighting | Recommended |
| ripgrep | Fast file content search | Optional |
| fd | Fast alternative to find | Optional |

---

## Core Features

### Aesthetic Prompt

Your prompt displays:
- Username in gold color
- Current directory in sage green
- Git branch (when in a repository)
- Elegant box-drawing characters

### Color Scheme

| Color | Hex | Usage |
|-------|-----|-------|
| Cream | #CCC3B8 | Prompt lines |
| Gold | #DABC94 | Username |
| Sage | #A8B49E | Directory path |
| Stone | #7A7373 | Git branch |
| Obsidian | #0F120E | Background accents |

---

## Navigation

### Z Command - Frecent Directory Jumping

**CRITICAL: Z requires a learning period before it works.**

#### How It Works

The Z command does NOT search your filesystem. It only knows about directories you have personally visited AFTER installing this configuration.

**Learning Process:**
1. Z starts with an empty database (`~/.z_data`)
2. Every time you `cd` into a directory, it gets recorded
3. After visiting directories, Z can jump to them by partial name

**Example Timeline:**

```bash
# Day 1 - Install configuration
source ~/.bashrc
z projects                    # ERROR: "no matches found for 'projects'"
                             # This is NORMAL - Z doesn't know this directory yet

cd ~/Documents/Projects       # Z records this visit
cd ~/Code/MyProject          # Z records this visit
cd ~                         # Return home

# Now Z knows these directories
z Projects                   # SUCCESS: jumps to ~/Documents/Projects
z MyPro                      # SUCCESS: jumps to ~/Code/MyProject
```

**Key Points:**
- Z does not scan your filesystem
- Z only knows directories you've visited since installation
- The database builds automatically as you navigate
- More visits = higher priority in matching

#### Basic Usage

```bash
z <partial-name>    # Jump to most frequent/recent directory matching the name
zi                  # Interactive selection with FZF
```

#### Interactive Mode (zi)

Opens an FZF menu showing all visited directories with timestamps. Use arrow keys to select.

```bash
zi                  # Show all tracked directories
zi project          # Filter to directories containing "project"
```

### Quick Navigation Aliases

```bash
..          # Go up one directory
...         # Go up two directories
....        # Go up three directories
.....       # Go up four directories

c           # Alias for cd (typo fix)
cdc         # Alias for cd (typo fix)
```

### mkcd - Create and Enter Directory

```bash
mkcd newproject     # Creates directory and cd's into it
```

---

## History & Search

### Smart Arrow Key History

**This is the most practical feature for daily use.**

Unlike normal history navigation, arrow keys search based on what you've typed.

**Usage:**
1. Type the beginning of a command (e.g., `git st`)
2. Press UP arrow
3. Only commands starting with "git st" appear
4. Press UP/DOWN to cycle through matches

**Example:**

```bash
$ cd /very/long/path/to/project/src
# Later...
$ cd    # Type "cd" then press UP arrow
# Immediately shows: cd /very/long/path/to/project/src
```

**Why This Matters:**

Traditional history: Press UP 50 times to find your command
Smart history: Type 2 letters, press UP once

### FZF History Search (Ctrl+R)

Fuzzy search across your entire command history.

**Usage:**
1. Press `Ctrl+R`
2. Type any part of the command
3. Arrow keys to navigate results
4. Enter to select, Esc to cancel

**Features:**
- Commands shown without timestamps (clean view)
- Fuzzy matching (scattered letters work)
- Most recent commands appear first
- Aesthetic color scheme

### History Settings

- Stores 50,000 commands in memory
- Keeps 100,000 commands in history file
- Ignores duplicate commands
- Syncs across all terminal windows
- Saves timestamps (hidden in display)

---

## Aliases Reference

### File Operations

```bash
ls          # ls --color=auto
ll          # ls -alF --color=auto (detailed list)
la          # ls -A --color=auto (show hidden files)
lh          # ls -lh --color=auto (human-readable sizes)
l           # ls -CF --color=auto

cat         # bat --style=plain (syntax highlighting)
tree        # tree -C (colored output)

v           # nvim
vi          # nvim
vim         # nvim
```

### Git Aliases

```bash
gs          # git status --short
ga          # git add
gc          # git commit
gp          # git push
gl          # git log --oneline --graph --decorate
gd          # git diff --color=always
gco         # git checkout
gb          # git branch
```

### System Management (Arch Linux)

```bash
u           # sudo pacman -Syu (update system)
i           # sudo pacman -S (install package)
upgrade     # sudo pacman -Syu
install     # sudo pacman -S
remove      # sudo pacman -Rns (remove with dependencies)
search      # pacman -Ss (search packages)
orphans     # Remove orphaned packages
```

### System Information

```bash
df          # df -h (disk usage)
free        # free -h (memory usage)
du          # du -h (directory size)
myip        # curl -s ifconfig.me (external IP)
ports       # netstat -tulanp (open ports)
```

### Utilities

```bash
e           # exit
open        # xdg-open (open files with default app)
nv          # watch -n 1 nvidia-smi (monitor GPU)
f           # feh --bg-fill (set wallpaper)
```

### Typo Fixes

All these work as shortcuts to avoid common typos:

```bash
# Clear variants
claer, clewar, clwear, clea, clae, clar  # All execute: clear

# CD variants
c, cdc                                    # Both execute: cd
```

### Shutdown Aliases

```bash
shutup
calmdown
takeiteasy
# All execute: shutdown now
```

---

## Custom Functions

### extract - Universal Archive Extractor

Automatically detects and extracts any archive format.

```bash
extract archive.tar.gz
extract file.zip
extract package.rar
```

**Supported Formats:**
- .tar.gz, .tar.bz2, .tgz, .tbz2, .tar
- .zip, .rar, .7z
- .gz, .bz2, .Z

### fe - Fuzzy Find and Edit

Interactive file finder with preview, opens in editor.

```bash
fe              # Search all files, preview with bat
# Arrow keys to navigate, Enter to open in nvim
```

### rg_fzf - Search File Contents

Find files containing specific text, with context preview.

```bash
rg_fzf 'search term'
# Shows files containing the text, preview with context
```

**Note:** Requires ripgrep to be installed.

### ducks - Show Largest Directories

Display largest directories in current location, sorted by size.

```bash
ducks           # Show top 10 largest directories
ducks 20        # Show top 20 largest directories
```

---

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+R` | Open FZF history search |
| `UP Arrow` | Search history backward (matching current input) |
| `DOWN Arrow` | Search history forward (matching current input) |
| `TAB` | Cycle through tab completions |
| `Ctrl+L` | Clear screen |
| `Ctrl+C` | Cancel current command |
| `Ctrl+A` | Move cursor to start of line |
| `Ctrl+E` | Move cursor to end of line |
| `Ctrl+W` | Delete word before cursor |
| `Ctrl+U` | Clear line before cursor |

---

## Common Misconceptions

### "Z command doesn't find my directories"

**Misconception:** Z searches your entire filesystem for directories.

**Reality:** Z only knows directories you've visited after installation.

**Solution:** Navigate to directories normally with `cd` first. After a few visits, Z will know them.

**Why It Works This Way:** Z is a "frecency" tool (frequency + recency). It learns your habits rather than scanning everything. This makes it fast and personalized.

### "Arrow keys aren't showing suggestions"

**Misconception:** This configuration has fish-like auto-suggestions that appear as you type.

**Reality:** This is not technically possible in bash without external tools. Instead, we use smart arrow key history.

**How It Actually Works:**
- Type the start of a command
- Press UP arrow
- See previous commands that START with what you typed
- This is more practical than visual suggestions

### "History search shows dates/times"

**Misconception:** FZF history should be clean.

**Reality:** It is clean. The configuration strips timestamps from FZF display.

**If You See Timestamps:** The configuration wasn't loaded properly. Run `source ~/.bashrc`.

### "Git branch not showing in prompt"

**Expected Behavior:** Git branch only appears when you're inside a git repository.

**Verification:**
```bash
cd ~/some-git-repo
# Prompt should show branch

cd ~
# Branch disappears (not in a git repo)
```

---

## Troubleshooting

### FZF Not Working

**Symptom:** Pressing Ctrl+R does nothing.

**Diagnosis:**
```bash
which fzf           # Should show path to fzf
fzf --version       # Should show version number
```

**Solution:**
```bash
sudo pacman -S fzf  # Install fzf
source ~/.bashrc    # Reload configuration
```

### Colors Not Displaying

**Symptom:** Prompt shows escape codes or no colors.

**Diagnosis:**
```bash
echo $TERM          # Should show xterm-256color or similar
```

**Solution:** Configure your terminal emulator to support 256 colors.

### Z Command Database Issues

**Symptom:** Z says "no matches found" for directories you've visited.

**Diagnosis:**
```bash
cat ~/.z_data       # Should show visited directories
```

**Solutions:**

If file is empty:
- You just installed the configuration
- Navigate to directories normally with `cd`
- Z will start tracking after a few visits

If file is missing:
```bash
touch ~/.z_data     # Create database file
source ~/.bashrc    # Reload
```

### Arrow Keys Show Weird Characters

**Symptom:** Pressing UP shows ^[[A or similar.

**Diagnosis:**
```bash
echo $SHELL         # Should show /bin/bash
```

**Solution:** Make sure you're using bash, not sh:
```bash
chsh -s /bin/bash   # Change default shell to bash
```

### Bat Not Working

**Symptom:** `cat` command shows errors.

**Diagnosis:**
```bash
which bat           # Should show path
```

**Solution:**

Install bat:
```bash
sudo pacman -S bat
```

Or disable the alias by commenting it out in .bashrc:
```bash
# if command -v bat &> /dev/null; then
#     alias cat="bat --style=plain"
# fi
```

---

## Customization

### Changing Colors

Colors are defined at the top of .bashrc using RGB values.

**Format:** `\[\e[38;2;R;G;Bm\]`

**Example:**
```bash
# Original
CREAM="\[\e[38;2;204;195;184m\]"

# Modified (bright cyan)
CREAM="\[\e[38;2;0;255;255m\]"
```

After editing, reload:
```bash
source ~/.bashrc
```

### Modifying the Prompt

The prompt (PS1) is defined around line 46.

**Variables:**
- `\u` - Username
- `\w` - Current directory (full path)
- `\W` - Current directory (basename only)
- `\h` - Hostname
- `\$(parse_git_branch)` - Git branch

**Box Drawing Characters:**
- `╭─` `╰─` - Corners
- `│` - Vertical line
- `❯` - Arrow prompt

### Adding Aliases

Add aliases in the aliases section (around line 80).

**Syntax:**
```bash
alias shortcut="full command"
```

**Examples:**
```bash
alias weather="curl wttr.in"
alias please="sudo"
alias tarball="tar -czf"
```

### Adding Functions

Add custom functions in the functions section (around line 430).

**Template:**
```bash
function_name() {
    # Your code here
}
```

**Example:**
```bash
backup() {
    cp "$1" "$1.backup.$(date +%Y%m%d)"
}
```

### Disabling Features

Comment out unwanted features with `#`:

**Disable Z tracking:**
```bash
# PROMPT_COMMAND="_z_add_to_db; history -a; history -c; history -r"
PROMPT_COMMAND="history -a; history -c; history -r"
```

**Disable git branch in prompt:**
```bash
# PS1="${CREAM}╭─${RESET} ${BOLD}${GOLD}\u${RESET} ${DIM}${STONE}in${RESET} ${BOLD}${SAGE}\w${RESET}${DIM}${STONE}\$(parse_git_branch)${RESET}
PS1="${CREAM}╭─${RESET} ${BOLD}${GOLD}\u${RESET} ${DIM}${STONE}in${RESET} ${BOLD}${SAGE}\w${RESET}
${CREAM}╰─${RESET} ${TAUPE}❯${RESET} "
```

---

## Advanced Configuration

### PATH Management

The configuration organizes PATH to avoid duplicates.

**Location:** Lines 29-49

**Structure:**
```bash
# Local binaries
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
```

This prevents the same path from being added multiple times on reload.

### History Configuration

**Settings:**
```bash
HISTCONTROL=ignoredups:erasedups   # No duplicate commands
HISTSIZE=50000                      # Commands in memory
HISTFILESIZE=100000                 # Commands in file
HISTTIMEFORMAT="%F %T "             # Timestamp format (hidden in FZF)
```

**Behavior:**
- Commands saved immediately after execution
- History syncs across all terminal windows
- Duplicates removed automatically

### Tab Completion Settings

**Features:**
- Case-insensitive completion
- Show completions immediately if ambiguous
- Colored prefix matching
- Visual statistics for file types
- Menu-style cycling with TAB

**Configuration:** Lines 320-330

---

## File Locations

```
~/.bashrc           # Main configuration file
~/.z_data           # Z command database
~/.bash_history     # Command history
```

---

## Restoring Original Configuration

If you need to revert to your original .bashrc:

```bash
cp ~/.bashrc.backup ~/.bashrc
source ~/.bashrc
```

---

## Technical Notes

### How Z Scoring Works

Z calculates a "frecency" score for each directory:

**Scoring:**
- Last hour: 100 points
- Last day: 50 points
- Last week: 25 points
- Older: 10 points

**Matching:**
- Partial string match (case-sensitive)
- Highest score wins
- Directory must still exist on filesystem

### FZF History Cleaning

The configuration strips timestamps using sed:

```bash
sed -E 's/^[ ]*[0-9]+[ ]+([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} )?//'
```

This removes:
- Leading whitespace
- Line numbers
- Timestamps in format: YYYY-MM-DD HH:MM:SS

### Smart Arrow Key Implementation

Uses readline's history-search-backward/forward:

```bash
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
```

This is native bash functionality, not a custom implementation.

---

## Known Limitations

1. **Z command** - Does not search filesystem, only tracks visited directories
2. **Color support** - Requires terminal with 256-color support
3. **Git prompt** - May slow down in very large repositories
4. **FZF** - Requires external installation, not included with bash
5. **History sync** - Slight delay between terminal windows (by design)

---

## Support

For issues or bugs:
1. Check the Troubleshooting section
2. Verify all dependencies are installed
3. Ensure you're running bash (not sh or zsh)
4. Check `~/.bashrc` for syntax errors

To report issues, include:
- Operating system and version
- Bash version: `bash --version`
- Terminal emulator being used
- Output of: `echo $TERM`

---

**Configuration File:** ~/.bashrc
**Version:** 2.0
**Last Updated:** 2026-02-06
