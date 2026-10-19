-- Pick the colorscheme for the active theme (run: theme <name>).
-- gruvbox uses gruvbox.nvim; every other theme uses colors/theme.lua.
return function()
    local ok, t = pcall(dofile, vim.fn.expand("~/.cache/theme/nvim.lua"))
    if ok and type(t) == "table" and t.name ~= "gruvbox" then
        vim.cmd("colorscheme theme")
    else
        vim.cmd("colorscheme gruvbox")
    end
end
