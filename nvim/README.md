# The Most Handsome Minimal Neovim Setup

---

## Table of Contents

1. [Installation](#installation)
2. [File Structure](#file-structure)
3. [Plugin List](#plugin-list)
4. [Key Bindings Reference](#key-bindings-reference)
5. [LSP Configuration](#lsp-configuration)
6. [Common Misconceptions](#common-misconceptions)
7. [Troubleshooting](#troubleshooting)
8. [Customization](#customization)

---

## Installation

### Prerequisites

```bash
# Neovim 0.9.0 or later
nvim --version

# Git (for plugin manager)
git --version

# Node.js (for LSP servers)
node --version

# Ripgrep (for Telescope grep)
rg --version

# FZF (for fuzzy finding)
fzf --version

# xclip (for system clipboard on Linux)
xclip -version
```

### Install Dependencies

```bash
# Arch Linux
sudo pacman -S neovim git nodejs npm ripgrep fzf xclip

# Ubuntu/Debian
sudo apt install neovim git nodejs npm ripgrep fzf xclip
```

### Setup Configuration

```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.backup

# Create config directory
mkdir -p ~/.config/nvim/lua/core

# Copy files
cp init.lua ~/.config/nvim/
cp options.lua ~/.config/nvim/lua/core/
cp keymaps.lua ~/.config/nvim/lua/core/
cp plugins.lua ~/.config/nvim/lua/

# Start Neovim (will auto-install lazy.nvim and plugins)
nvim
```

### First Launch

On first launch, the configuration will:
1. Install lazy.nvim plugin manager automatically
2. Install all plugins (wait for completion)
3. If any errors occur, run `:Lazy sync` to retry

After plugins install:
```vim
:Mason         " Open Mason to install LSP servers
:checkhealth   " Verify everything is working
```

---

## File Structure

```
~/.config/nvim/
├── init.lua              # Main entry point
└── lua/
    ├── core/
    │   ├── options.lua   # Vim options and settings
    │   └── keymaps.lua   # Key mappings
    └── plugins.lua       # Plugin definitions
```

**File Purposes:**

| File | Purpose |
|------|---------|
| init.lua | Entry point, loads modules, autocmds |
| core/options.lua | All vim options (line numbers, tabs, etc) |
| core/keymaps.lua | All key bindings |
| plugins.lua | Plugin installation and configuration |

---

## Plugin List

### Core Functionality

| Plugin | Purpose |
|--------|---------|
| lazy.nvim | Plugin manager |
| nvim-lspconfig | LSP client configuration |
| mason.nvim | LSP/formatter/linter installer |
| nvim-cmp | Autocompletion engine |
| LuaSnip | Snippet engine |
| nvim-treesitter | Syntax highlighting and parsing |

### UI Enhancements

| Plugin | Purpose |
|--------|---------|
| gruvbox.nvim | Color scheme |
| lualine.nvim | Statusline |
| indent-blankline.nvim | Indent guides |
| nvim-highlight-colors | Color preview |
| dashboard-nvim | Start screen |
| which-key.nvim | Keybinding helper |

### File Navigation

| Plugin | Purpose |
|--------|---------|
| telescope.nvim | Fuzzy finder |
| fzf.vim | Alternative fuzzy finder |
| nvim-tree.lua | File explorer |

### Editing Utilities

| Plugin | Purpose |
|--------|---------|
| Comment.nvim | Easy commenting |
| nvim-autopairs | Auto-close brackets |
| nvim-surround | Surround text objects |
| nvim-spectre | Find and replace |

### Development Tools

| Plugin | Purpose |
|--------|---------|
| trouble.nvim | Diagnostics panel |
| gitsigns.nvim | Git integration |
| none-ls.nvim | Formatters and linters |
| toggleterm.nvim | Terminal integration |

### Session Management

| Plugin | Purpose |
|--------|---------|
| auto-session | Auto-save/restore sessions |
| mini.bufremove | Smart buffer deletion |

### Integration

| Plugin | Purpose |
|--------|---------|
| vim-tmux-navigator | Seamless tmux navigation |

---

## Key Bindings Reference

### Leader Key

Leader key is set to `Space`.

All bindings shown with `<leader>` require pressing Space first.

### General

| Key | Mode | Action |
|-----|------|--------|
| `<leader>w` | Normal | Save file |
| `<leader>q` | Normal | Quit window |
| `<leader>Q` | Normal | Quit all |
| `kj` | Insert/Visual | Exit to normal mode |
| `Esc` | Normal | Clear search highlight |

### Window Navigation

| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+h` | Normal | Move to left window |
| `Ctrl+j` | Normal | Move to bottom window |
| `Ctrl+k` | Normal | Move to top window |
| `Ctrl+l` | Normal | Move to right window |

**Note:** Works seamlessly with tmux when vim-tmux-navigator is installed in both.

### Window Resizing

| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+Up` | Normal | Increase height |
| `Ctrl+Down` | Normal | Decrease height |
| `Ctrl+Left` | Normal | Decrease width |
| `Ctrl+Right` | Normal | Increase width |

### Text Editing

| Key | Mode | Action |
|-----|------|--------|
| `<` | Visual | Indent left (keeps selection) |
| `>` | Visual | Indent right (keeps selection) |
| `J` | Visual | Move selected text down |
| `K` | Visual | Move selected text up |

### Scrolling

| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+d` | Normal | Scroll down (cursor centered) |
| `Ctrl+u` | Normal | Scroll up (cursor centered) |
| `n` | Normal | Next search result (centered) |
| `N` | Normal | Previous search result (centered) |

### LSP

| Key | Mode | Action |
|-----|------|--------|
| `gd` | Normal | Go to definition |
| `gD` | Normal | Go to declaration |
| `gi` | Normal | Go to implementation |
| `gr` | Normal | Show references |
| `K` | Normal | Show hover information |
| `<leader>r` | Normal | Rename symbol |
| `<leader>ca` | Normal | Code actions |
| `<leader>f` | Normal | Format document |
| `<leader>o` | Normal | Organize imports |

### Diagnostics

| Key | Mode | Action |
|-----|------|--------|
| `[d` | Normal | Previous diagnostic |
| `]d` | Normal | Next diagnostic |
| `<leader>de` | Normal | Show diagnostic error |
| `<leader>dl` | Normal | Diagnostics to location list |

### Trouble (Diagnostics Panel)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>xx` | Normal | Toggle Trouble |
| `<leader>xw` | Normal | Workspace diagnostics |
| `<leader>xd` | Normal | Document diagnostics |
| `<leader>xq` | Normal | Quickfix list |
| `<leader>xl` | Normal | Location list |

### Telescope (Fuzzy Finder)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ff` | Normal | Find files |
| `<leader>fg` | Normal | Live grep |
| `<leader>fb` | Normal | Find buffers |
| `<leader>fh` | Normal | Help tags |
| `<leader>fr` | Normal | Recent files |
| `<leader>fc` | Normal | Commands |
| `<leader>fk` | Normal | Keymaps |
| `<leader>fs` | Normal | Document symbols |
| `<leader>fw` | Normal | Workspace symbols |

**Inside Telescope:**
- `Ctrl+j` - Move selection down
- `Ctrl+k` - Move selection up
- `Enter` - Select item
- `Esc` - Close

### FZF

| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+p` | Normal | Find files |

### File Explorer

| Key | Mode | Action |
|-----|------|--------|
| `<leader>e` | Normal | Toggle file explorer |
| `<leader>ef` | Normal | Find current file in explorer |

**Inside nvim-tree:**
- `a` - Create file
- `d` - Delete file
- `r` - Rename file
- `x` - Cut file
- `c` - Copy file
- `p` - Paste file
- `R` - Refresh tree
- `H` - Toggle hidden files
- `?` - Help

### Buffer Management

| Key | Mode | Action |
|-----|------|--------|
| `Tab` | Normal | Next buffer |
| `Shift+Tab` | Normal | Previous buffer |
| `<leader>bd` | Normal | Delete buffer |
| `<leader>bD` | Normal | Force delete buffer |

### Git

| Key | Mode | Action |
|-----|------|--------|
| `<leader>gb` | Normal | Toggle line blame |
| `<leader>gp` | Normal | Preview hunk |
| `<leader>gr` | Normal | Reset hunk |
| `<leader>gs` | Normal | Stage hunk |
| `<leader>gu` | Normal | Undo stage hunk |

### Terminal

| Key | Mode | Action |
|-----|------|--------|
| `<leader>tf` | Normal | Floating terminal |
| `<leader>th` | Normal | Horizontal terminal |
| `<leader>tv` | Normal | Vertical terminal |
| `Ctrl+\` | Normal | Toggle terminal |
| `Esc` / `kj` | Terminal | Exit terminal mode |

### Find and Replace

| Key | Mode | Action |
|-----|------|--------|
| `<leader>S` | Normal | Toggle Spectre |
| `<leader>sw` | Normal | Search current word |
| `<leader>sw` | Visual | Search selection |

### Clipboard

| Key | Mode | Action |
|-----|------|--------|
| `<leader>y` | Normal/Visual | Yank to system clipboard |
| `<leader>Y` | Normal | Yank line to system clipboard |
| `<leader>p` | Normal/Visual | Paste from system clipboard |
| `<leader>P` | Normal/Visual | Paste before from system clipboard |

### Quickfix List

| Key | Mode | Action |
|-----|------|--------|
| `<leader>co` | Normal | Open quickfix |
| `<leader>cc` | Normal | Close quickfix |
| `[q` | Normal | Previous quickfix item |
| `]q` | Normal | Next quickfix item |

### Toggle Options

| Key | Mode | Action |
|-----|------|--------|
| `<leader>n` | Normal | Toggle line numbers |
| `<leader>tw` | Normal | Toggle word wrap |

---

## LSP Configuration

### Installed Language Servers

The configuration auto-installs these LSP servers via Mason:

| Language | Server | Trigger |
|----------|--------|---------|
| Python | pyright | .py files |
| JavaScript/TypeScript | ts_ls | .js, .ts files |
| HTML | html | .html files |
| CSS | cssls | .css files |
| C/C++ | clangd | .c, .cpp files |
| C# | omnisharp | .cs files |
| Java | jdtls | .java files |
| HTML/JSX | emmet_ls | .html, .jsx files |
| Vim | vimls | .vim files |
| Lua | lua_ls | .lua files |

### Installing Additional LSP Servers

```vim
:Mason                    " Open Mason UI
" Navigate with j/k, press 'i' to install
```

**Or via command:**
```vim
:MasonInstall rust-analyzer
:MasonInstall gopls
```

### LSP Commands

| Command | Purpose |
|---------|---------|
| `:LspInfo` | Show LSP client info |
| `:LspStart` | Start LSP client |
| `:LspStop` | Stop LSP client |
| `:LspRestart` | Restart LSP client |

---

## Common Misconceptions

### "LSP not working for my language"

**Misconception:** LSP should work automatically for all file types.

**Reality:** LSP servers must be installed via Mason for each language.

**Solution:**
```vim
:Mason                    " Open Mason
" Find your language server
" Press 'i' to install
```

Common servers:
- Rust: rust-analyzer
- Go: gopls
- PHP: intelephense
- Ruby: solargraph

### "Autocomplete not showing"

**Possible Causes:**

1. **LSP not running:** Check `:LspInfo`
2. **LSP not installed:** Run `:Mason`
3. **File not saved:** Some LSP servers require saved files
4. **Trigger not pressed:** Press `Ctrl+Space` to trigger

**Verification:**
```vim
:checkhealth nvim-cmp
:checkhealth lsp
```

### "kj doesn't exit insert mode"

**Expected Behavior:** Pressing `k` then `j` quickly exits insert mode.

**Timeout Issue:** If you type too slowly, it registers as separate keys.

**Adjust timeout:**
```lua
-- In options.lua
vim.opt.timeoutlen = 500    -- Increase to 700 or 1000 if needed
```

### "Colors look wrong"

**Requirement:** Terminal must support 24-bit color.

**Verification:**
```bash
echo $COLORTERM
# Should show: truecolor or 24bit
```

**Fix for terminal:**
```bash
# Add to .bashrc
export COLORTERM=truecolor
```

### "Telescope grep not working"

**Requirement:** Requires ripgrep to be installed.

**Install:**
```bash
sudo pacman -S ripgrep    # Arch
sudo apt install ripgrep  # Ubuntu
```

### "Session not restoring"

**Common Causes:**

1. Started in home directory (suppressed by config)
2. Started in Downloads (suppressed by config)
3. Session never saved

**Manual session save:**
```vim
:SessionSave
```

**Check session location:**
```bash
ls ~/.local/share/nvim/sessions/
```

---

## Troubleshooting

### Neovim Won't Start

**Symptom:** Error messages or blank screen on startup.

**Diagnosis:**
```bash
nvim --noplugin          # Start without plugins
nvim -u NONE             # Start with no config
```

**Common Issues:**

1. **Syntax error in config:**
   - Check recent changes
   - Look for missing commas in plugin list

2. **Plugin conflict:**
   ```vim
   :Lazy health         " Check plugin health
   ```

3. **Corrupted plugin cache:**
   ```bash
   rm -rf ~/.local/share/nvim
   rm -rf ~/.cache/nvim
   nvim                  " Will reinstall everything
   ```

### LSP Not Starting

**Symptom:** No autocompletion, no diagnostics.

**Diagnosis:**
```vim
:LspInfo                 " Check LSP status
:Mason                   " Verify server installed
```

**Solutions:**

1. **Server not installed:**
   ```vim
   :Mason
   " Press 'i' on the server
   ```

2. **Server failed to start:**
   ```vim
   :LspLog                  " Check error messages
   ```

3. **Wrong file type:**
   ```vim
   :set filetype?           " Verify file type detected
   :set filetype=python     " Set manually if needed
   ```

### Treesitter Errors

**Symptom:** Syntax highlighting broken or error messages.

**Solution:**
```vim
:TSUpdate                  " Update all parsers
:TSInstall <language>      " Install specific parser
:TSUninstall <language>    " Remove and reinstall
```

**Check health:**
```vim
:checkhealth nvim-treesitter
```

### Clipboard Not Working

**Symptom:** System clipboard copy/paste fails.

**Requirements:**

Linux:
```bash
sudo pacman -S xclip      # X11
sudo pacman -S wl-clipboard    # Wayland
```

**Verify:**
```vim
:checkhealth provider
" Should show clipboard provider available
```

### Telescope Issues

**Slow performance:**
```vim
" Add to telescope setup in plugins.lua
defaults = {
  file_ignore_patterns = { "node_modules", ".git" }
}
```

**Not finding files:**
```vim
:Telescope find_files hidden=true    " Include hidden files
```

### Plugin Won't Install

**Symptom:** Plugin fails to install via lazy.nvim.

**Solutions:**

1. **Check internet connection**

2. **Clear cache:**
   ```vim
   :Lazy clear
   :Lazy sync
   ```

3. **Install manually:**
   ```vim
   :Lazy install <plugin-name>
   ```

4. **Check lazy.nvim log:**
   ```vim
   :Lazy log
   ```

### Terminal Colors Wrong

**Symptom:** Colors in nvim terminal differ from outside.

**Check terminal setting:**
```vim
:echo $TERM
" Inside nvim should show: screen-256color
```

**Fix in options.lua:**
```lua
vim.opt.termguicolors = true    " Should be present
```

### Auto-pairs Conflicting

**Symptom:** Unwanted bracket behavior.

**Disable temporarily:**
```vim
:lua require("nvim-autopairs").disable()
```

**Disable permanently:**
```lua
-- Comment out in plugins.lua
-- {
--   "windwp/nvim-autopairs",
--   ...
-- },
```

---

## Customization

### Changing Color Scheme

**Available themes:**
- gruvbox (currently active)
- solarized-osaka (installed but inactive)

**Switch to solarized-osaka:**
```lua
-- In plugins.lua, find gruvbox section:
-- Comment out: vim.cmd("colorscheme gruvbox")

-- Find solarized-osaka section:
-- Uncomment: vim.cmd("colorscheme solarized-osaka")
```

**Install new theme:**
```lua
-- Add to plugins.lua
{
  "folke/tokyonight.nvim",
  config = function()
    vim.cmd("colorscheme tokyonight")
  end,
}
```

### Changing Leader Key

```lua
-- In keymaps.lua, change:
vim.g.mapleader = ' '    -- Current (Space)
-- To:
vim.g.mapleader = ','    -- Use comma instead
```

### Adjusting Tab Width

```lua
-- In options.lua
vim.opt.tabstop = 4        -- Change to 2 for 2-space tabs
vim.opt.shiftwidth = 4     -- Change to 2 to match
```

### Disabling Plugins

**Temporary:**
```vim
:Lazy              " Open Lazy UI
" Navigate to plugin, press 'x' to disable
```

**Permanent:**
```lua
-- In plugins.lua, comment out the plugin:
-- {
--   "plugin/name",
--   ...
-- },
```

### Adding Custom Keymaps

```lua
-- In keymaps.lua
map('n', '<leader>custom', ':YourCommand<CR>', { desc = 'Your description' })
```

**Examples:**
```lua
map('n', '<leader>h', ':nohlsearch<CR>', { desc = 'Clear highlight' })
map('n', '<C-s>', ':w<CR>', { desc = 'Save with Ctrl+S' })
map('i', '<C-s>', '<Esc>:w<CR>a', { desc = 'Save in insert mode' })
```

### Changing File Explorer Width

```lua
-- In plugins.lua, nvim-tree config:
view = {
  width = 35,    -- Change to desired width
},
```

### Adding Formatters/Linters

```lua
-- In plugins.lua, none-ls config:
sources = {
  null_ls.builtins.formatting.prettier,    -- JavaScript/TypeScript
  null_ls.builtins.formatting.black,       -- Python
  null_ls.builtins.diagnostics.eslint,     -- JavaScript linting
  null_ls.builtins.formatting.stylua,      -- Lua formatting
},
```

**Install tools via Mason:**
```vim
:Mason
" Install: prettier, black, eslint_d, stylua
```

### Disabling Auto-pairs

```lua
-- In plugins.lua, comment out:
-- {
--   "windwp/nvim-autopairs",
--   event = "InsertEnter",
--   config = function()
--     require("nvim-autopairs").setup()
--   end,
-- },
```

### Changing Completion Behavior

```lua
-- In plugins.lua, nvim-cmp mapping section:
["<CR>"] = cmp.mapping.confirm({ select = true })
-- Change to:
["<CR>"] = cmp.mapping.confirm({ select = false })
-- Now Enter won't auto-select first item
```

---

## Advanced Configuration

### Autocommands

Located in `init.lua`. Current autocommands:

| Autocommand | Purpose |
|-------------|---------|
| YankHighlight | Flash yanked text |
| TrimWhitespace | Remove trailing whitespace on save |
| CloseWithQ | Close help/man pages with 'q' |
| AutoCreateDir | Create parent directories on save |
| RestoreCursor | Restore cursor position when reopening |
| CheckTime | Check for file changes |
| ResizeSplits | Auto-resize splits on window resize |

### Custom Commands

| Command | Purpose |
|---------|---------|
| `:Format` | Format current buffer |
| `:ToggleDiagnostics` | Toggle LSP diagnostics |

### Adding Custom Commands

```lua
-- In init.lua
vim.api.nvim_create_user_command('CommandName', function()
  -- Your code here
end, { desc = 'Description' })
```

**Example:**
```lua
vim.api.nvim_create_user_command('RemoveTrailingSpaces', function()
  vim.cmd([[%s/\s\+$//e]])
end, { desc = 'Remove all trailing spaces' })
```

---

## Performance

### Lazy Loading

Most plugins are lazy-loaded to improve startup time.

**Check startup time:**
```vim
:Lazy profile
```

**Disable lazy loading for a plugin:**
```lua
{
  "plugin/name",
  lazy = false,    -- Load immediately
},
```

### Optimization Settings

Current optimizations in `options.lua`:
- `lazyredraw = true` - Don't redraw during macros
- `updatetime = 300` - Faster CursorHold events
- `timeoutlen = 500` - Reasonable key sequence timeout

### Disabled Built-in Plugins

The config disables unused built-in plugins to reduce overhead.

**Re-enable if needed:**
```lua
-- In options.lua, remove from disabled_built_ins list
-- For example, to enable netrw:
-- Remove "netrw" and "netrwPlugin" from the list
```

---

## File Locations

```
~/.config/nvim/           # Configuration directory
~/.local/share/nvim/      # Plugin installation, sessions
~/.local/state/nvim/      # Undo files, shada
~/.cache/nvim/            # Cache files
```

---

## Backup and Restore

### Backup Configuration

```bash
tar -czf nvim-config-backup.tar.gz ~/.config/nvim
```

### Restore Configuration

```bash
rm -rf ~/.config/nvim
tar -xzf nvim-config-backup.tar.gz -C ~/
```

### Clean Install

```bash
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
# Then reinstall config
```

---

## Version Requirements

- Neovim: 0.9.0 or later (0.10.0 recommended)
- Node.js: 14.0 or later
- Git: Any recent version
- Ripgrep: 13.0 or later
- FZF: 0.27.0 or later

**Check versions:**
```bash
nvim --version
node --version
git --version
rg --version
fzf --version
```

---

**Configuration Version:** 2.0
**Last Updated:** 2026-02-06
**Neovim Version:** 0.9.0+
