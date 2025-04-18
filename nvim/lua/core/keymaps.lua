local map = vim.keymap.set

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

map('n', '<leader>w', ':w<CR>', { desc = 'Save file' }) 
map('n', '<leader>q', ':q<CR>', { desc = 'Quit window' }) 

local map = vim.keymap.set


map('i', 'kj', '<Esc>', { desc = 'Exit Insert Mode with kj' })

map('v', 'kj', '<Esc>', { desc = 'Exit Visual Mode with kj' })
map('s', 'kj', '<Esc>', { desc = 'Exit Select Mode with kj' }) 

local map = vim.keymap.set

map('n', 'gd', ':lua vim.lsp.buf.definition()<CR>', { desc = 'Go to Definition' })

map('n', 'K', ':lua vim.lsp.buf.hover()<CR>', { desc = 'Show Hover Information' })

map('n', '<leader>o', ':lua vim.lsp.buf.organize_imports()<CR>', { desc = 'Organize Imports' })

map('n', '<leader>r', ':lua vim.lsp.buf.rename()<CR>', { desc = 'Rename Symbol' })

map('n', '<leader>f', ':lua vim.lsp.buf.code_action()<CR>', { desc = 'Code Actions' })

map('n', '[d', ':lua vim.diagnostic.goto_prev()<CR>', { desc = 'Previous Diagnostic' })
map('n', ']d', ':lua vim.diagnostic.goto_next()<CR>', { desc = 'Next Diagnostic' })
