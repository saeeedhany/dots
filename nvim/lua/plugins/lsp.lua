return {
    {
        "williamboman/mason.nvim",
        dependencies = { "williamboman/mason-lspconfig.nvim" },
        config = function()
            require("mason").setup({
                ui = { icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                }},
            })
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "pyright", "ts_ls", "html", "cssls", "clangd",
                    "omnisharp", "jdtls", "emmet_ls", "vimls", "lua_ls",
                },
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            vim.diagnostic.config({
                virtual_text = true,
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = " ",
                        [vim.diagnostic.severity.WARN] = " ",
                        [vim.diagnostic.severity.HINT] = " ",
                        [vim.diagnostic.severity.INFO] = " ",
                    },
                },
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })

            -- lua_ls special config
            vim.lsp.config("lua_ls", {
                capabilities = capabilities,
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        diagnostics = { globals = { "vim" } },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false,
                        },
                        telemetry = { enable = false },
                    },
                },
            })

            -- All other servers
            for _, lsp in ipairs({ "pyright", "ts_ls", "html", "cssls",
                "clangd", "omnisharp", "jdtls", "emmet_ls", "vimls" }) do
                vim.lsp.config(lsp, { capabilities = capabilities })
            end

            -- Enable all servers
            vim.lsp.enable({ "lua_ls", "pyright", "ts_ls", "html", "cssls",
                "clangd", "omnisharp", "jdtls", "emmet_ls", "vimls" })
        end,
    },
}
