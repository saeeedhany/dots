-- File: ~/.config/nvim/lua/options.lua

-- General Options
vim.opt.number = true          -- Show line numbers
vim.opt.relativenumber = true  -- Show relative line numbers
vim.opt.tabstop = 4            -- Set tab width to 4 spaces
vim.opt.shiftwidth = 4         -- Indentation level is 4 spaces
vim.opt.expandtab = true       -- Use spaces instead of tabs
vim.opt.smartindent = true     -- Enable smart indentation
vim.opt.autoindent = true      -- Copy indent from previous line
vim.opt.ignorecase = true      -- Ignore case in search patterns
vim.opt.smartcase = true       -- Override ignorecase if search contains uppercase letters
vim.opt.hlsearch = true        -- Highlight search results
vim.opt.incsearch = true       -- Incremental search
vim.opt.cursorline = true      -- Highlight the current line
vim.opt.termguicolors = true   -- Enable true colors for terminals that support it
vim.opt.scrolloff = 8          -- Keep 8 lines of context above and below the cursor
vim.opt.sidescrolloff = 8      -- Keep 8 columns of context horizontally
vim.opt.splitright = true      -- Open vertical splits to the right
vim.opt.splitbelow = true      -- Open horizontal splits below
vim.opt.updatetime = 300       -- Faster update time for CursorHold events
vim.opt.timeoutlen = 500       -- Time to wait for a key mapping sequence (in ms)

-- Disable Text Wrap
vim.opt.wrap = false           -- Disable text wrapping
