-- ~/.config/nvim/lua/plugins.lua

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  print("Installing lazy.nvim...")
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin definitions
require("lazy").setup({

  -- THEMES ----------------------------------------
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.termguicolors = true
      vim.opt.background = "dark"
      require("solarized-osaka").setup({
        transparent = false,
        styles = { sidebars = "dark", floats = "dark" },
      })
      vim.cmd("colorscheme solarized-osaka")
    end,
  },

  -- LSP + MASON -----------------------------------
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
          "omnisharp", "jdtls", "emmet_ls", "vimls",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.diagnostic.config({
        virtual_text = true, signs = true,
        underline = true, update_in_insert = false,
      })

      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      for _, lsp in ipairs({ "pyright", "ts_ls", "html", "cssls",
                            "clangd", "omnisharp", "jdtls", "emmet_ls", "vimls" }) do
        lspconfig[lsp].setup({ capabilities = capabilities })
      end
    end,
  },

  -- AUTOCOMPLETE ----------------------------------
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
      })
    end,
  },

  -- TREESITTER ------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "python", "javascript", "typescript", "html",
          "css", "c", "cpp", "java", "c_sharp", "vim",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- FILE EXPLORER ---------------------------------
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
    end,
  },

  {
    'junegunn/fzf',
    run = function() vim.fn['fzf#install']() end
  },
  {
    'junegunn/fzf.vim'
  },

  -- FUZZY FINDER ----------------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup()
    end,
  },

  -- UTILITIES -------------------------------------
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          section_separators = { left = "", right = "" },
          component_separators = { left = "", right = "" },
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

  -- SESSION MANAGEMENT ----------------------------
  {
    "rmagatti/auto-session",
    config = function()
      require("auto-session").setup()
    end,
  },

  -- TERMINAL INTEGRATION --------------------------
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup()
    end,
  },

  -- TMUX NAVIGATION -------------------------------
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
})

