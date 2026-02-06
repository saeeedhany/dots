vim.loader.enable()
vim.opt.termguicolors = true

require('core.options')
require('core.keymaps')
require('plugins')

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
  group = 'YankHighlight',
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
  end,
})

-- Remove trailing whitespace on save
augroup('TrimWhitespace', { clear = true })
autocmd('BufWritePre', {
  group = 'TrimWhitespace',
  pattern = '*',
  command = [[%s/\s\+$//e]],
})

-- Close certain filetypes with 'q'
augroup('CloseWithQ', { clear = true })
autocmd('FileType', {
  group = 'CloseWithQ',
  pattern = {
    'help',
    'startuptime',
    'qf',
    'lspinfo',
    'man',
    'checkhealth',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
  end,
})

-- Auto-create parent directories when saving a file
augroup('AutoCreateDir', { clear = true })
autocmd('BufWritePre', {
  group = 'AutoCreateDir',
  callback = function(event)
    if event.match:match('^%w%w+://') then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- Restore cursor position when opening a file
augroup('RestoreCursor', { clear = true })
autocmd('BufReadPost', {
  group = 'RestoreCursor',
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Check if file changed outside of Neovim
augroup('CheckTime', { clear = true })
autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = 'CheckTime',
  command = 'checktime',
})

-- Resize splits when window is resized
augroup('ResizeSplits', { clear = true })
autocmd('VimResized', {
  group = 'ResizeSplits',
  callback = function()
    vim.cmd('tabdo wincmd =')
  end,
})

-- Format the entire buffer
vim.api.nvim_create_user_command('Format', function()
  vim.lsp.buf.format({ async = true })
end, { desc = 'Format current buffer' })

-- Toggle diagnostics
local diagnostics_active = true
vim.api.nvim_create_user_command('ToggleDiagnostics', function()
  diagnostics_active = not diagnostics_active
  if diagnostics_active then
    vim.diagnostic.enable()
  else
    vim.diagnostic.disable()
  end
end, { desc = 'Toggle diagnostics' })
