return {
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("trouble").setup({
                icons = true,
                fold_open = "",
                fold_closed = "",
                signs = {
                    error = "",
                    warning = "",
                    hint = "",
                    information = "",
                },
            })
        end,
    },
}
