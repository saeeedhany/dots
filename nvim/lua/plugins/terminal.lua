return {
    -- Floating/split terminal
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            require("toggleterm").setup({
                size = 20,
                open_mapping = [[<C-\>]],
                direction = "float",
                float_opts = {
                    border = "curved",
                },
            })
        end,
    },

    -- Tmux pane navigation
    {
        "christoomey/vim-tmux-navigator",
        lazy = false,
    },

    -- Session management
    {
        "rmagatti/auto-session",
        config = function()
            require("auto-session").setup({
                log_level = "error",
                suppressed_dirs = { "~/", "~/Downloads", "/" },
            })
            vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
        end,
    },
}
