return {
    {
        "nvimtools/none-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local null_ls = require("null-ls")
            null_ls.setup({
                sources = {
                    -- Put whatever you want ya 3asal <3 (I'm not gay wallahi!)
                },
            })
        end,
    },
}
