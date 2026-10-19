-- Fuzzy finder (bound to <C-p> for find_files, see core/keymaps.lua)
return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
        },
    },
}
