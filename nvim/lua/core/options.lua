-- Line Numbers
vim.opt.number = true                 -- Show absolute line numbers
vim.opt.relativenumber = true         -- Show relative line numbers
vim.opt.numberwidth = 4               -- Width of the number column

-- Indentation
vim.opt.tabstop = 4                   -- Number of spaces a tab counts for
vim.opt.shiftwidth = 4                -- Number of spaces for each indentation
vim.opt.expandtab = true              -- Convert tabs to spaces
vim.opt.smartindent = true            -- Smart autoindenting on new lines
vim.opt.autoindent = true             -- Copy indent from current line when starting new line
vim.opt.breakindent = true            -- Wrapped lines continue with same indent

-- Search
vim.opt.ignorecase = true             -- Ignore case in search patterns
vim.opt.smartcase = true              -- Override ignorecase if search has uppercase
vim.opt.hlsearch = true               -- Highlight all search matches
vim.opt.incsearch = true              -- Show match as search proceeds

-- UI
vim.opt.cursorline = true             -- Highlight the current line
vim.opt.termguicolors = true          -- Enable 24-bit RGB colors
vim.opt.signcolumn = "yes"            -- Always show sign column (prevents text shift)
vim.opt.colorcolumn = "80"            -- Show vertical line at column 80
vim.opt.showmode = false              -- Don't show mode (already in statusline)
vim.opt.ruler = true                  -- Show cursor position in status line
vim.opt.showcmd = true                -- Show incomplete commands in status line
vim.opt.laststatus = 3                -- Global statusline

-- Scrolling
vim.opt.scrolloff = 8                 -- Minimum lines to keep above/below cursor
vim.opt.sidescrolloff = 8             -- Minimum columns to keep left/right of cursor

-- Splits
vim.opt.splitright = true             -- Open vertical splits to the right
vim.opt.splitbelow = true             -- Open horizontal splits below

-- Text Wrapping
vim.opt.wrap = false                  -- Disable line wrapping
vim.opt.linebreak = true              -- Break lines at word boundaries when wrap is on

-- Performance
vim.opt.updatetime = 300              -- Faster completion (default is 4000ms)
vim.opt.timeoutlen = 500              -- Time to wait for mapped sequence (ms)
vim.opt.lazyredraw = true             -- Don't redraw while executing macros

-- Backup and Swap
vim.opt.backup = false                -- Don't create backup files
vim.opt.writebackup = false           -- Don't create backup before overwriting
vim.opt.swapfile = false              -- Don't use swapfile
vim.opt.undofile = true               -- Enable persistent undo
vim.opt.undolevels = 10000            -- Maximum number of undo levels

-- Clipboard
vim.opt.clipboard = "unnamedplus"     -- Use system clipboard

-- Mouse
vim.opt.mouse = "a"                   -- Enable mouse support in all modes

-- Completion
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.pumheight = 10                -- Maximum items in popup menu

-- File Handling
vim.opt.fileencoding = "utf-8"        -- File encoding
vim.opt.autoread = true               -- Auto reload files changed outside vim
vim.opt.hidden = true                 -- Allow switching buffers without saving

-- Wildmenu
vim.opt.wildmenu = true               -- Enhanced command line completion
vim.opt.wildmode = "longest:full,full" -- Command line completion mode
vim.opt.wildignore = { "*.o", "*~", "*.pyc", "*/.git/*", "*/.hg/*", "*/.svn/*" }

-- Folding
vim.opt.foldmethod = "expr"           -- Use expression for folding
vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- Use treesitter for folding
vim.opt.foldlevel = 99                -- Start with all folds open
vim.opt.foldenable = false            -- Don't fold by default

-- Misc
vim.opt.iskeyword:append("-")         -- Treat dash as part of word
vim.opt.formatoptions:remove({ "c", "r", "o" }) -- Don't auto-continue comments
vim.opt.shortmess:append("c")         -- Don't show completion messages
vim.opt.whichwrap:append("<,>,[,],h,l") -- Allow moving to next/prev line

-- Disable some builtin vim plugins
local disabled_built_ins = {
  "2html_plugin",
  "getscript",
  "getscriptPlugin",
  "gzip",
  "logipat",
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "matchit",
  "tar",
  "tarPlugin",
  "rrhelper",
  "spellfile_plugin",
  "vimball",
  "vimballPlugin",
  "zip",
  "zipPlugin",
  "tutor",
  "rplugin",
  "syntax",
  "synmenu",
  "optwin",
  "compiler",
  "bugreport",
  "ftplugin",
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end
