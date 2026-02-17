return {
    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "gruvbox",
                    section_separators = { left = "", right = "" },
                    component_separators = { left = "", right = "" },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { "filename" },
                    lualine_x = { "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            })
        end,
    },

    -- Indent guides
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        config = function()
            require("ibl").setup({
                indent = { char = "│" },
                scope = {
                    enabled = true,
                    show_start = true,
                    show_end = false,
                },
                exclude = {
                    filetypes = { "dashboard", "alpha", "starter", "lazy", "NvimTree" },
                },
            })
        end,
    },

    -- Color preview
    {
        "brenoprata10/nvim-highlight-colors",
        config = function()
            require("nvim-highlight-colors").setup({
                render = "background",
                enable_named_colors = true,
                enable_tailwind = true,
            })
        end,
    },

    -- Keybinding helper
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            local wk = require("which-key")
            wk.setup({
                plugins = {
                    marks = true,
                    registers = true,
                    spelling = { enabled = true, suggestions = 20 },
                },
            })
            wk.add({
                { "<leader>f", group = "Find/Telescope" },
                { "<leader>t", group = "Toggle/Terminal" },
                { "<leader>d", group = "Diagnostics" },
                { "<leader>g", group = "Git" },
            })
        end,
    },

    -- Dashboard
    {
        "nvimdev/dashboard-nvim",
        event = "VimEnter",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("dashboard").setup({
                theme = "hyper",
                config = {
                    week_header = { enable = true },
                    shortcut = {
                        { desc = "󰊳 Update", group = "@property", action = "Lazy update", key = "u" },
                        {
                            icon = " ",
                            icon_hl = "@variable",
                            desc = "Files",
                            group = "Label",
                            action = "Telescope find_files",
                            key = "f",
                        },
                    },
                    footer = {},
                },
            })
        end,
    },
}
