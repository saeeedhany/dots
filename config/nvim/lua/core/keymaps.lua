local map = vim.keymap.set

-- Everything else is stock Neovim: <C-w>hjkl for windows, :bnext/:bprev,
-- gd/gD/K for LSP already work via Neovim 0.11's built-in tagfunc + hover,
-- and gra/grn/grr/gri/gO are Neovim's built-in LSP keymaps (see :h lsp-defaults).

-- Exit to Normal mode
map({ 'i', 'v', 's' }, 'kj', '<Esc>', { desc = 'Exit to Normal mode' })
map('t', 'kj', [[<C-\><C-n>]], { desc = 'Exit terminal mode' })

-- Fuzzy find files
map('n', '<C-p>', '<cmd>Telescope find_files<cr>', { desc = 'Find files' })
