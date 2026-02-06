local map = vim.keymap.set

-- Set leader keys
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

map('n', '<leader>w', ':w<CR>', { desc = 'Save file' })
map('n', '<leader>q', ':q<CR>', { desc = 'Quit window' })
map('n', '<leader>Q', ':qa<CR>', { desc = 'Quit all' })

-- Exit modes with kj
map('i', 'kj', '<Esc>', { desc = 'Exit Insert Mode' })
map('v', 'kj', '<Esc>', { desc = 'Exit Visual Mode' })
map('s', 'kj', '<Esc>', { desc = 'Exit Select Mode' })

-- Better window navigation
map('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
map('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom window' })
map('n', '<C-k>', '<C-w>k', { desc = 'Move to top window' })
map('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Resize windows with arrows
map('n', '<C-Up>', ':resize +2<CR>', { desc = 'Increase window height' })
map('n', '<C-Down>', ':resize -2<CR>', { desc = 'Decrease window height' })
map('n', '<C-Left>', ':vertical resize -2<CR>', { desc = 'Decrease window width' })
map('n', '<C-Right>', ':vertical resize +2<CR>', { desc = 'Increase window width' })

-- Better indenting
map('v', '<', '<gv', { desc = 'Indent left and reselect' })
map('v', '>', '>gv', { desc = 'Indent right and reselect' })

-- Move text up and down
map('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move text down' })
map('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move text up' })

-- Keep cursor centered when scrolling
map('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })
map('n', 'n', 'nzzzv', { desc = 'Next search result and center' })
map('n', 'N', 'Nzzzv', { desc = 'Previous search result and center' })

-- Clear search highlight
map('n', '<Esc>', ':nohl<CR>', { desc = 'Clear search highlight' })

map('n', 'gd', function() vim.lsp.buf.definition() end, { desc = 'Go to Definition' })
map('n', 'gD', function() vim.lsp.buf.declaration() end, { desc = 'Go to Declaration' })
map('n', 'gi', function() vim.lsp.buf.implementation() end, { desc = 'Go to Implementation' })
map('n', 'gr', function() vim.lsp.buf.references() end, { desc = 'Show References' })
map('n', 'K', function() vim.lsp.buf.hover() end, { desc = 'Show Hover Information' })
map('n', '<leader>o', function() vim.lsp.buf.organize_imports() end, { desc = 'Organize Imports' })
map('n', '<leader>r', function() vim.lsp.buf.rename() end, { desc = 'Rename Symbol' })
map('n', '<leader>ca', function() vim.lsp.buf.code_action() end, { desc = 'Code Actions' })
map('n', '<leader>f', function() vim.lsp.buf.format() end, { desc = 'Format Document' })

map('n', '[d', function() vim.diagnostic.goto_prev() end, { desc = 'Previous Diagnostic' })
map('n', ']d', function() vim.diagnostic.goto_next() end, { desc = 'Next Diagnostic' })
map('n', '<leader>de', function() vim.diagnostic.open_float() end, { desc = 'Show Diagnostic Error' })
map('n', '<leader>dl', function() vim.diagnostic.setloclist() end, { desc = 'Diagnostics to Location List' })

-- Trouble (Diagnostic Panel)
map('n', '<leader>xx', ':Trouble diagnostics toggle<CR>', { desc = 'Toggle Trouble' })
map('n', '<leader>xw', ':Trouble diagnostics toggle filter.buf=0<CR>', { desc = 'Trouble Workspace Diagnostics' })
map('n', '<leader>xd', ':Trouble diagnostics toggle filter.buf=0<CR>', { desc = 'Trouble Document Diagnostics' })
map('n', '<leader>xq', ':Trouble quickfix toggle<CR>', { desc = 'Trouble Quickfix' })
map('n', '<leader>xl', ':Trouble loclist toggle<CR>', { desc = 'Trouble Location List' })

map('n', '<leader>ff', ':Telescope find_files<CR>', { desc = 'Find Files' })
map('n', '<leader>fg', ':Telescope live_grep<CR>', { desc = 'Live Grep' })
map('n', '<leader>fb', ':Telescope buffers<CR>', { desc = 'Find Buffers' })
map('n', '<leader>fh', ':Telescope help_tags<CR>', { desc = 'Help Tags' })
map('n', '<leader>fr', ':Telescope oldfiles<CR>', { desc = 'Recent Files' })
map('n', '<leader>fc', ':Telescope commands<CR>', { desc = 'Commands' })
map('n', '<leader>fk', ':Telescope keymaps<CR>', { desc = 'Keymaps' })
map('n', '<leader>fs', ':Telescope lsp_document_symbols<CR>', { desc = 'Document Symbols' })
map('n', '<leader>fw', ':Telescope lsp_workspace_symbols<CR>', { desc = 'Workspace Symbols' })

-- FZF (alternative fuzzy finder)
map('n', '<C-p>', ':Files<CR>', { noremap = true, silent = true, desc = 'FZF Files' })

map('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle File Explorer' })
map('n', '<leader>ef', ':NvimTreeFindFile<CR>', { desc = 'Find Current File in Explorer' })

map('n', '<Tab>', ':bnext<CR>', { desc = 'Next Buffer' })
map('n', '<S-Tab>', ':bprevious<CR>', { desc = 'Previous Buffer' })
map('n', '<leader>bd', ':lua require("mini.bufremove").delete()<CR>', { desc = 'Delete Buffer' })
map('n', '<leader>bD', ':lua require("mini.bufremove").delete(0, true)<CR>', { desc = 'Force Delete Buffer' })

map('n', '<leader>gb', ':Gitsigns toggle_current_line_blame<CR>', { desc = 'Toggle Git Blame' })
map('n', '<leader>gp', ':Gitsigns preview_hunk<CR>', { desc = 'Preview Git Hunk' })
map('n', '<leader>gr', ':Gitsigns reset_hunk<CR>', { desc = 'Reset Git Hunk' })
map('n', '<leader>gs', ':Gitsigns stage_hunk<CR>', { desc = 'Stage Git Hunk' })
map('n', '<leader>gu', ':Gitsigns undo_stage_hunk<CR>', { desc = 'Undo Stage Git Hunk' })

map('n', '<leader>tf', ':ToggleTerm direction=float<CR>', { desc = 'Toggle Floating Terminal' })
map('n', '<leader>th', ':ToggleTerm direction=horizontal<CR>', { desc = 'Toggle Horizontal Terminal' })
map('n', '<leader>tv', ':ToggleTerm direction=vertical<CR>', { desc = 'Toggle Vertical Terminal' })

-- Terminal mode mappings
map('t', '<Esc>', [[<C-\><C-n>]], { desc = 'Exit Terminal Mode' })
map('t', 'kj', [[<C-\><C-n>]], { desc = 'Exit Terminal Mode' })

map('n', '<leader>S', ':lua require("spectre").toggle()<CR>', { desc = 'Toggle Spectre (Find & Replace)' })
map('n', '<leader>sw', ':lua require("spectre").open_visual({select_word=true})<CR>', { desc = 'Search Current Word' })
map('v', '<leader>sw', ':lua require("spectre").open_visual()<CR>', { desc = 'Search Current Selection' })

-- Toggle line numbers
map('n', '<leader>n', ':set number! relativenumber!<CR>', { desc = 'Toggle Line Numbers' })

-- Toggle word wrap
map('n', '<leader>tw', ':set wrap!<CR>', { desc = 'Toggle Word Wrap' })

-- Yank to system clipboard
map({'n', 'v'}, '<leader>y', '"+y', { desc = 'Yank to System Clipboard' })
map('n', '<leader>Y', '"+Y', { desc = 'Yank Line to System Clipboard' })

-- Paste from system clipboard
map({'n', 'v'}, '<leader>p', '"+p', { desc = 'Paste from System Clipboard' })
map({'n', 'v'}, '<leader>P', '"+P', { desc = 'Paste Before from System Clipboard' })

-- Quick fix list navigation
map('n', '<leader>co', ':copen<CR>', { desc = 'Open Quickfix List' })
map('n', '<leader>cc', ':cclose<CR>', { desc = 'Close Quickfix List' })
map('n', '[q', ':cprev<CR>', { desc = 'Previous Quickfix Item' })
map('n', ']q', ':cnext<CR>', { desc = 'Next Quickfix Item' })
