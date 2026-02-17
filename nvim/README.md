# The Most Handsome Minimal Neovim Setup

It's so peak BTW

---

## Requirements

```bash
# Arch
sudo pacman -S neovim git nodejs npm ripgrep fzf xclip

# Ubuntu
sudo apt install neovim git nodejs npm ripgrep fzf xclip
```

> Neovim 0.11+ is required.

---

## Setup

```bash
git clone <this-repo> ~/.config/nvim
nvim  # lazy.nvim will auto-install everything
```

Then inside Neovim:
```vim
:Mason   " install LSP servers
```

---

## File Structure

```
~/.config/nvim/
├── init.lua              # entry point + lazy bootstrap
├── .luarc.json           # suppresses lua_ls vim global warnings
└── lua/
    ├── core/
    │   ├── options.lua
    │   └── keymaps.lua
    └── plugins/          # one file per category, auto-loaded by lazy
        ├── lsp.lua
        ├── cmp.lua
        ├── treesitter.lua
        ├── colorscheme.lua
        ├── ui.lua
        ├── explorer.lua
        ├── fuzzy.lua
        ├── git.lua
        ├── editing.lua
        ├── diagnostics.lua
        ├── formatting.lua
        └── terminal.lua
```

---

## Key Bindings

Leader key: `Space`

### General
| Key | Action |
|-----|--------|
| `<leader>w` | Save |
| `<leader>q` | Quit |
| `kj` | Exit insert mode |

### LSP
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | References |
| `K` | Hover info |
| `<leader>r` | Rename |
| `<leader>ca` | Code actions |
| `<leader>f` | Format |

### Navigation
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>e` | File explorer |
| `Ctrl+p` | FZF files |

### Diagnostics
| Key | Action |
|-----|--------|
| `[d` / `]d` | Prev/next diagnostic |
| `<leader>xx` | Toggle Trouble panel |
| `<leader>de` | Show error float |

### Git
| Key | Action |
|-----|--------|
| `<leader>gb` | Toggle line blame |
| `<leader>gs` | Stage hunk |
| `<leader>gp` | Preview hunk |

### Terminal
| Key | Action |
|-----|--------|
| `<leader>tf` | Floating terminal |
| `Ctrl+\` | Toggle terminal |
| `Esc` | Exit terminal mode |

### Buffers
| Key | Action |
|-----|--------|
| `Tab` / `Shift+Tab` | Next/prev buffer |
| `<leader>bd` | Delete buffer |

---

## Adding a Plugin

Create a new file in `lua/plugins/` — lazy picks it up automatically:

```lua
-- lua/plugins/myplugin.lua
return {
  {
    "author/plugin-name",
    config = function()
      require("plugin-name").setup({})
    end,
  },
}
```
