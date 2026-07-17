return {
  -- Example with lazy.nvim
  {
    'https://codeberg.org/esensar/nvim-dev-container',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function() 
      require("devcontainer").setup{}
    end
  },
  -- 1. Treesitter Context
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      require("treesitter-context").setup({
        enable = true,
        max_lines = 5,
        trim_scope = "outer",
      })
    end
  },

-- 2. LSP Config & Mason (Includes LTeX for Spell/Grammar)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- Markdown Oxide requires specific capabilities for tags and links
      capabilities.workspace = {
        didChangeWatchedFiles = {
          dynamicRegistration = true,
        },
      }
      local lspconfig = require("lspconfig")

      -- Enable Native Vim Spelling for specific files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "text", "gitcommit", "norg" },
        callback = function()
          vim.opt_local.spell = true
          vim.opt_local.spelllang = "en_us"
        end,
      })

      require("mason-lspconfig").setup({
        -- Added markdown_oxide here
        ensure_installed = { "pyright", "clangd", "ltex", "markdown_oxide" },
        handlers = {
          -- Default handler
          function(server_name)
            lspconfig[server_name].setup({
              capabilities = capabilities,
            })
          end,

          -- Markdown Oxide specific setup
          ["markdown_oxide"] = function()
            lspconfig.markdown_oxide.setup({
              capabilities = capabilities,
              -- On_attach isn't strictly required here since you use a global LspAttach autocmd below
            })
          end,

          -- Specific handler for clangd
          ["clangd"] = function()
            lspconfig.clangd.setup({
              capabilities = {
                offsetEncoding = { "utf-16" }, 
              },
              cmd = {
                "clangd",
                "--background-index",
                "--query-driver=C:/NXP/S32DS.3.5/S32DS/tools/gnu-gcc-arm-none-eabi-9-2019-q4-major/bin/arm-none-eabi-gcc.exe",
                "--header-insertion=never",
                "--fallback-style=llvm",
              },
            })
          end,

          ["ltex"] = function()
            -- ... your existing ltex config ...
          end,
        },
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }), 
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          vim.keymap.set('n', '<leader>tg', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', '<leader>th', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>tj', vim.lsp.buf.references, opts)
          
          vim.keymap.set({ 'n', 'v' }, '<leader>xa', vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },
  -- 4. Neo-tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    opts = {
      filesystem = {
        filtered_items = { visible = true },
      },
    },
  },

  -- 5. Telescope
  {
    "nvim-telescope/telescope.nvim", 
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case", "--glob", "!tags"
          },
          file_ignore_patterns = { "tags", "node_modules", ".git" },
        },
      })
      -- Add Telescope spell suggest binding
      vim.keymap.set('n', '<leader>ss', require('telescope.builtin').spell_suggest, { desc = "Spelling Suggestions" })
    end
  },

  -- 6. Colorschemes
  { "ankushbhagats/pastel.nvim", lazy = false, priority = 1000, config = function() vim.cmd([[colorscheme pasteldark]]) end },
  { "folke/tokyonight.nvim", lazy = false, priority = 1000 },
  { "Scysta/pink-panic.nvim", lazy = false, priority = 1000, dependencies = { "rktjmp/lush.nvim" } },

  -- 7. Utilities & Movement
  { "folke/which-key.nvim", lazy = true },
  -- { "nvim-neorg/neorg", ft = "norg", opts = { load = { ["core.defaults"] = {} } } },
  { "dstein64/vim-startuptime", cmd = "StartupTime" },
  { "hrsh7th/nvim-cmp", event = "InsertEnter", dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer" } },
  { "stevearc/dressing.nvim", event = "VeryLazy" },
  { "Wansmer/treesj", keys = { { "J", "<cmd>TSJToggle<cr>", desc = "Join Toggle" } }, opts = { use_default_keymaps = false, max_join_length = 150 } },
  { "monaqa/dial.nvim", keys = { "<C-a>", { "<C-x>", mode = "n" } } },
  { "tpope/vim-repeat" },
  -- Abolish is great for fixing common typos automatically
  { "tpope/vim-abolish", event = "BufReadPost" },
  -- 8. Leap
  {
    url = "https://codeberg.org/andyg/leap.nvim",
    config = function()
      require('leap').add_default_mappings()
    end,
  },
  {
    "startup-nvim/startup.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim", "nvim-telescope/telescope-file-browser.nvim" },
    config = function()
      local startup = require("startup")
      local settings = require("config.startup_nvim")
      startup.setup(settings)    
    end
  },
}
