# Enhanced Tmux Configuration

---

## Table of Contents

1. [Installation](#installation)
2. [Plugin Management](#plugin-management)
3. [Color Scheme](#color-scheme)
4. [Key Bindings Reference](#key-bindings-reference)
5. [Productivity Features](#productivity-features)
6. [Session Management](#session-management)
7. [Copy Mode](#copy-mode)
8. [Common Misconceptions](#common-misconceptions)
9. [Troubleshooting](#troubleshooting)
10. [Customization](#customization)

---

## Installation

### Quick Setup

```bash
# Backup existing configuration
cp ~/.tmux.conf ~/.tmux.conf.backup

# Install new configuration
cp .tmux.conf ~/.tmux.conf

# Install TPM (Tmux Plugin Manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Start tmux
tmux

# Install plugins (inside tmux)
# Press: Ctrl+b, then I (capital i)
```

### Required Dependencies

```bash
# Arch Linux
sudo pacman -S tmux xclip

# Ubuntu/Debian
sudo apt install tmux xclip
```

### First-Time Setup

After installation, you must install the plugins:

1. Start tmux: `tmux`
2. Press `Ctrl+b` then `I` (capital I)
3. Wait for plugins to install
4. Press `Ctrl+b` then `r` to reload configuration

---

## Plugin Management

### Installed Plugins

| Plugin | Purpose |
|--------|---------|
| tpm | Plugin manager |
| tmux-sensible | Sensible defaults |
| tmux-resurrect | Save/restore sessions |
| tmux-continuum | Auto-save sessions |
| tmux-yank | Enhanced clipboard |
| vim-tmux-navigator | Seamless vim/tmux navigation |

### Plugin Commands

```bash
# Inside tmux
Ctrl+b I         # Install plugins
Ctrl+b U         # Update plugins
Ctrl+b alt+u     # Uninstall plugins not in config
```

### Session Persistence

Sessions automatically save every 15 minutes and restore on tmux start.

**Manual session management:**
```bash
Ctrl+b Ctrl+s    # Save session manually
Ctrl+b Ctrl+r    # Restore session manually
```

**Session directory:** `~/.tmux/resurrect/`

---

## Color Scheme

The configuration uses the same aesthetic palette as the enhanced bashrc.

| Color | Hex | Usage |
|-------|-----|-------|
| Cream | #CCC3B8 | Primary text, highlights |
| Mauve | #93877C | Active window, borders |
| Gray | #504F50 | Inactive borders |
| Dark | #0F120E | Background |
| Muted | #7A7373 | Secondary text |

---

## Key Bindings Reference

### Prefix Key

All commands start with the prefix: `Ctrl+b`

Example: `Ctrl+b c` means:
1. Press `Ctrl+b`
2. Release both keys
3. Press `c`

### Window Management

| Key | Action |
|-----|--------|
| `c` | Create new window |
| `x` | Kill current pane |
| `X` | Kill current window |
| `Alt+h` | Previous window (no prefix needed) |
| `Alt+l` | Next window (no prefix needed) |
| `Alt+1-9` | Jump to window 1-9 (no prefix needed) |
| `Tab` | Last window |
| `,` | Rename window |
| `<` | Move window left |
| `>` | Move window right |

### Pane Management

| Key | Action |
|-----|--------|
| `\|` | Split vertically |
| `-` | Split horizontally |
| `h` | Move to left pane |
| `j` | Move to down pane |
| `k` | Move to up pane |
| `l` | Move to right pane |
| `H` | Resize pane left |
| `J` | Resize pane down |
| `K` | Resize pane up |
| `L` | Resize pane right |
| `Ctrl+h` | Resize pane left (faster) |
| `Ctrl+j` | Resize pane down (faster) |
| `Ctrl+k` | Resize pane up (faster) |
| `Ctrl+l` | Resize pane right (faster) |
| `f` | Toggle pane fullscreen |
| `=` | Equalize all panes |
| `b` | Break pane to new window |
| `j` | Join pane from another window |
| `>` (lower) | Swap pane down |
| `<` (lower) | Swap pane up |

### Layout Presets

| Key | Layout |
|-----|--------|
| `Alt+1` | Even horizontal |
| `Alt+2` | Even vertical |
| `Alt+3` | Main horizontal |
| `Alt+4` | Main vertical |
| `Alt+5` | Tiled |

### Session Management

| Key | Action |
|-----|--------|
| `S` | Choose session |
| `N` | Create new session |
| `Alt+s` | Choose session (no prefix needed) |
| `$` | Rename session |
| `BTab` | Last session |

### Copy Mode

| Key | Action |
|-----|--------|
| `v` | Enter copy mode |
| `Escape` | Exit copy mode |
| `/` | Search forward |
| `?` | Search backward |

**While in copy mode:**

| Key | Action |
|-----|--------|
| `v` | Begin selection |
| `Ctrl+v` | Rectangle selection |
| `y` | Copy and exit |
| `Escape` | Cancel selection |

### Utility Commands

| Key | Action |
|-----|--------|
| `r` | Reload configuration |
| `t` | Toggle status bar |
| `Ctrl+k` | Clear history and screen |
| `s` | Toggle pane synchronization |
| `m` | Toggle activity monitoring |
| `M` | Monitor silence (prompts for seconds) |
| `:` | Command prompt |
| `p` | Paste buffer |

---

## Productivity Features

### Pane Synchronization

Send the same commands to all panes simultaneously.

**Usage:**
```bash
Ctrl+b s         # Toggle sync on/off
# Status shows: "Sync ON" or "Sync OFF"
```

**Common Use Cases:**
- Configure multiple servers identically
- Run same tests across environments
- Monitor multiple logs simultaneously

### Window Monitoring

Track activity in background windows.

**Activity Monitoring:**
```bash
Ctrl+b m         # Toggle activity monitoring
# Window name inverts when activity detected
```

**Silence Monitoring:**
```bash
Ctrl+b M         # Prompts for seconds
# Alerts when window is silent for specified time
```

### Session Resurrection

Sessions persist across reboots and tmux restarts.

**How It Works:**
- Auto-saves every 15 minutes
- Restores on tmux start
- Preserves:
  - Window layouts
  - Pane arrangements
  - Working directories
  - Running programs (with resurrect strategies)

**Manual Control:**
```bash
Ctrl+b Ctrl+s    # Force save now
Ctrl+b Ctrl+r    # Restore last save
```

### Mouse Support

Full mouse integration enabled by default.

**Features:**
- Click to select pane
- Drag to resize panes
- Scroll to navigate history
- Double-click to select word
- Triple-click to select line
- Click status bar to switch windows

### Working Directory Persistence

New panes/windows open in the current pane's directory.

**Behavior:**
```bash
Ctrl+b |         # New pane in current directory
Ctrl+b c         # New window in current directory
```

### Fast Pane Switching

Navigate between panes without thinking.

**With vim-tmux-navigator:**
- Works seamlessly with vim/nvim
- Same keys switch between vim splits and tmux panes
- No mental context switch required

---

## Session Management

### Creating Sessions

**From outside tmux:**
```bash
tmux                          # Create unnamed session
tmux new -s work              # Create named session
tmux new -s work -d           # Create detached session
```

**From inside tmux:**
```bash
Ctrl+b N                      # Prompts for session name
```

### Switching Sessions

```bash
Ctrl+b S                      # List all sessions
Ctrl+b Alt+s                  # Quick session switcher
Ctrl+b BTab                   # Toggle between last two sessions
```

**From outside tmux:**
```bash
tmux ls                       # List sessions
tmux attach -t work           # Attach to session
tmux switch -t work           # Switch to session
```

### Session Workflow

**Recommended pattern:**
```bash
# Create sessions by project
tmux new -s personal
tmux new -s work
tmux new -s project-name

# Switch between them
Ctrl+b Alt+s    # Interactive selector
```

### Killing Sessions

```bash
# From inside session
Ctrl+b : kill-session

# From outside tmux
tmux kill-session -t work
tmux kill-server              # Kill all sessions
```

---

## Copy Mode

### Entering Copy Mode

```bash
Ctrl+b v         # Enter copy mode
Ctrl+b [         # Enter copy mode (default)
```

### Navigation in Copy Mode

**Vim-style movement:**
```
h, j, k, l       # Left, down, up, right
w, b             # Word forward, word backward
0, $             # Start of line, end of line
gg, G            # Top of buffer, bottom of buffer
Ctrl+d, Ctrl+u   # Half page down, half page up
Ctrl+f, Ctrl+b   # Full page down, full page up
```

### Selection and Copy

```bash
v                # Begin selection
Ctrl+v           # Rectangle selection
y                # Copy selection and exit
Escape           # Cancel and exit
```

### Searching

```bash
/pattern         # Search forward
?pattern         # Search backward
n                # Next match
N                # Previous match
```

### Paste

```bash
Ctrl+b p         # Paste last buffer
```

---

## Common Misconceptions

### "Vim-tmux-navigator isn't working"

**Misconception:** The plugin should work immediately after installation.

**Reality:** Vim/Neovim needs matching configuration.

**Solution:**

Install the vim plugin:
```vim
" In your .vimrc or init.vim
Plug 'christoomey/vim-tmux-navigator'
```

Without this, vim won't pass navigation commands to tmux.

### "Mouse scroll doesn't work"

**Expected Behavior:** Mouse scroll works differently inside/outside copy mode.

**Outside copy mode:**
- Scroll sends scroll events to running program
- Use for scrolling less, vim, etc.

**Inside copy mode:**
- Scroll navigates tmux history
- Enter copy mode first: `Ctrl+b v`

### "Sessions aren't restoring"

**Common Causes:**

1. TPM not installed: `ls ~/.tmux/plugins/tpm`
2. Plugins not installed: Press `Ctrl+b I`
3. Continuum disabled: Check `@continuum-restore` in config

**Verification:**
```bash
ls ~/.tmux/resurrect/
# Should show timestamp files
```

### "New panes don't preserve directory"

**This is the expected behavior.**

The configuration is designed to preserve working directory. If it's not working:

1. Verify tmux version: `tmux -V` (needs 1.9+)
2. Check split commands use `-c "#{pane_current_path}"`
3. Reload config: `Ctrl+b r`

### "Status bar disappeared"

**Cause:** Accidentally toggled status bar.

**Solution:**
```bash
Ctrl+b t         # Toggle status bar on/off
```

---

## Troubleshooting

### TPM Not Installing Plugins

**Symptom:** `Ctrl+b I` does nothing.

**Diagnosis:**
```bash
ls ~/.tmux/plugins/tpm
# Should show tpm files
```

**Solution:**
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# Inside tmux: Ctrl+b I
```

### Colors Not Displaying

**Symptom:** Colors look wrong or show as gray.

**Diagnosis:**
```bash
echo $TERM
# Should show "screen-256color" inside tmux
```

**Solution:**

Add to .bashrc or .zshrc:
```bash
export TERM=xterm-256color
```

Then reload tmux configuration.

### Copy to Clipboard Not Working

**Symptom:** Copied text doesn't reach system clipboard.

**Requirements:**
```bash
# Install xclip
sudo pacman -S xclip    # Arch
sudo apt install xclip  # Ubuntu/Debian

# Verify it's running
which xclip
```

**Alternative:**

For Wayland, use wl-clipboard:
```bash
sudo pacman -S wl-clipboard

# Edit .tmux.conf, replace xclip with:
bind -T copy-mode-vi y send -X copy-pipe-and-cancel "wl-copy"
```

### Tmux Won't Start

**Symptom:** Error messages on `tmux` command.

**Diagnosis:**
```bash
tmux -V             # Check version
tmux -f /dev/null   # Start with no config
```

**Common Issues:**

1. Syntax error in config: Check recent changes
2. Missing dependencies: Install xclip
3. Old tmux version: Update to 2.1+

**Reset Configuration:**
```bash
mv ~/.tmux.conf ~/.tmux.conf.broken
tmux -f /dev/null
# If this works, config has errors
```

### Pane Navigation Not Working

**Symptom:** `Ctrl+b h/j/k/l` doesn't move between panes.

**Check:**
```bash
# Inside tmux
Ctrl+b :list-keys | grep select-pane
# Should show h, j, k, l bindings
```

**Solution:**
```bash
Ctrl+b r            # Reload config
# Or restart tmux
tmux kill-server
tmux
```

### Vim-Tmux-Navigator Conflicts

**Symptom:** Can't navigate between vim and tmux.

**Diagnosis:**

1. Check vim plugin installed
2. Check tmux plugin installed: `ls ~/.tmux/plugins/vim-tmux-navigator`
3. Verify both configs loaded

**Solution:**

Must have BOTH:
- Vim plugin: `Plug 'christoomey/vim-tmux-navigator'`
- Tmux plugin: Listed in .tmux.conf plugins section

### Session Restoration Issues

**Symptom:** Sessions don't restore after restart.

**Check:**
```bash
ls ~/.tmux/resurrect/
# Should have timestamp files

cat ~/.tmux/resurrect/last
# Should symlink to recent save
```

**Fix:**

If directory is empty:
```bash
# Save manually
Ctrl+b Ctrl+s

# Check again
ls -la ~/.tmux/resurrect/
```

---

## Customization

### Changing Colors

Colors are defined in the status bar styling section.

**Find and replace hex values:**
```bash
# Current colors
#CCC3B8  # Cream
#93877C  # Mauve
#504F50  # Gray
#0F120E  # Dark
#7A7373  # Muted

# Example: Change cream to cyan
# Find: #CCC3B8
# Replace with: #00FFFF
```

After editing:
```bash
Ctrl+b r         # Reload config
```

### Changing Prefix Key

Default prefix is `Ctrl+b`. To change to `Ctrl+a`:

```bash
# Add to .tmux.conf
set -g prefix C-a
unbind C-b
bind C-a send-prefix
```

### Adding Custom Key Bindings

Add bindings in the key bindings section.

**Syntax:**
```bash
bind key-name command

# Examples
bind R source-file ~/.tmux.conf  # Uppercase R to reload
bind T clock-mode                 # Uppercase T for clock
bind C-x kill-session             # Ctrl+b Ctrl+x kills session
```

### Disabling Mouse

```bash
# Change in .tmux.conf
set -g mouse off
```

### Changing Status Bar Position

```bash
# Change in .tmux.conf
set -g status-position top    # Move to top
```

### Adding Status Bar Information

**CPU usage example:**
```bash
# Requires 'bc' to be installed
set -g status-right "#[fg=#7A7373]CPU: #(top -bn1 | grep 'Cpu' | awk '{print $2}')% "
```

**Memory usage example:**
```bash
set -g status-right "#[fg=#7A7373]MEM: #(free -h | awk '/^Mem:/ {print $3}') "
```

### Disabling Plugins

Comment out unwanted plugins:
```bash
# set -g @plugin 'tmux-plugins/tmux-continuum'
```

Then:
```bash
Ctrl+b alt+u     # Uninstall removed plugins
```

---

## Advanced Features

### Window Indexing

Windows and panes start at index 1 (not 0) for easier keyboard access.

**Reasoning:** Number keys 1-9 are in order, 0 is at the end of keyboard.

### Escape Time

Set to 0 for instant response to Escape key.

**Impact:** Critical for vim users inside tmux.

### Aggressive Resize

Resizes window to smallest client viewing it.

**Benefit:** Better multi-client experience.

### Repeat Time

Set to 600ms for resize commands.

**Benefit:** Hold key to continuously resize panes.

---

## Integration with Other Tools

### Vim/Neovim Integration

With vim-tmux-navigator:
- `Ctrl+h/j/k/l` works in both vim and tmux
- No context switch needed
- Seamless navigation

**Setup required in vim:**
```vim
Plug 'christoomey/vim-tmux-navigator'
```

### Terminal Multiplexing Strategy

**Recommended usage pattern:**

1. One tmux session per project
2. Multiple windows per session
3. Multiple panes per window

**Example:**
```bash
Session: work
├── Window 1: editor (vim in panes)
├── Window 2: servers (running processes)
├── Window 3: tests (test output)
└── Window 4: shell (general commands)
```

### SSH Integration

Tmux persists across SSH disconnections.

**Usage:**
```bash
# On remote server
tmux new -s dev
# Work...
# Disconnect SSH

# Reconnect later
ssh server
tmux attach -t dev
# Everything still there
```

---

## Performance Notes

### History Limit

Set to 50,000 lines (up from default 2,000).

**Impact:** More memory usage, but keeps extensive scroll history.

**Adjust if needed:**
```bash
set -g history-limit 10000    # Reduce for less memory
```

### Status Update Interval

Status bar updates every 5 seconds.

**Trade-off:** More frequent = more CPU, less = stale info.

### Auto-Save Interval

Sessions save every 15 minutes.

**Trade-off:** More frequent = more disk I/O, less = data loss risk.

---

## File Locations

```
~/.tmux.conf                    # Main configuration
~/.tmux/plugins/                # Installed plugins
~/.tmux/resurrect/              # Saved sessions
```

---

## Restoring Original Configuration

```bash
cp ~/.tmux.conf.backup ~/.tmux.conf
tmux kill-server
tmux
```

---

## Version Requirements

- Tmux: 2.1 or later (3.0+ recommended)
- xclip: Any version
- Git: For TPM installation

**Check version:**
```bash
tmux -V
```

---

**Configuration File:** ~/.tmux.conf  
**Version:** 2.0  
**Last Updated:** 2026-02-06
