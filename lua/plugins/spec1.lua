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

  -- 1b. Treesitter itself (main branch: no more setup()/highlight-on-by-
  -- default, parsers are installed and started explicitly).
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
      -- nvim-treesitter only ships a "systemverilog" parser (no separate
      -- "verilog" one); it parses plain Verilog fine, so reuse it there too.
      require("nvim-treesitter").install({ "systemverilog" })
      vim.treesitter.language.register("systemverilog", "verilog")

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "verilog", "systemverilog" },
        callback = function()
          -- pcall: the parser may still be installing on first run; the
          -- highlight simply won't start until the buffer is reopened.
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },

  -- 1c. Linting (nvim-lint) — verilator does real elaboration/semantic
  -- checks (undeclared signals, width mismatches, latch inference, ...)
  -- that verible's per-file syntax/style checker can't catch.
  {
    "mfussenegger/nvim-lint",
    ft = { "verilog", "systemverilog" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        verilog = { "verilator" },
        systemverilog = { "verilator" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        pattern = { "*.v", "*.sv", "*.svh", "*.vh" },
        callback = function()
          lint.try_lint()
        end,
      })
    end,
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
      -- Enable Native Vim Spelling for specific files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "text", "gitcommit", "norg" },
        callback = function()
          vim.opt_local.spell = true
          vim.opt_local.spelllang = "en_us"
        end,
      })

      -- mason-lspconfig v2 no longer supports `handlers`; per-server config
      -- goes through vim.lsp.config() and servers are auto-enabled by
      -- mason-lspconfig's `automatic_enable` (on by default).
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      vim.lsp.config("clangd", {
        capabilities = vim.tbl_deep_extend("force", capabilities, {
          offsetEncoding = { "utf-16" },
        }),
        cmd = {
          "clangd",
          "--background-index",
          "--query-driver=C:/NXP/S32DS.3.5/S32DS/tools/gnu-gcc-arm-none-eabi-9-2019-q4-major/bin/arm-none-eabi-gcc.exe",
          "--header-insertion=never",
          "--fallback-style=llvm",
        },
      })

      vim.lsp.config("ltex", {
        -- ltex-ls 16 bundles a LanguageTool grammar.xml that trips the JDK's
        -- default XML entity limits on modern Java, so the server dies with
        -- "Could not activate rules" before it ever attaches. 0 = no limit.
        cmd_env = {
          JAVA_OPTS = "-Djdk.xml.totalEntitySizeLimit=0 -Djdk.xml.entityExpansionLimit=0",
        },
        settings = {
          ltex = {
            language = "en-US",
          },
        },
      })

      -- Verible's language server (verible-verilog-ls) for Verilog/SystemVerilog.
      vim.lsp.config("verible", {
        cmd = {
          "verible-verilog-ls",
          -- Use a project's .rules.verible_lint if present; otherwise fall
          -- back to verible's normal "default" rule set. (--ruleset=all
          -- was tried and is way too noisy — full naming/style pedantry,
          -- not just real issues. verilator (nvim-lint) covers actual
          -- semantic bugs instead.)
          "--rules_config_search",
          -- Hover is marked experimental upstream and off by default.
          "--lsp_enable_hover",
        },
      })

      require("mason-lspconfig").setup({
        -- Added markdown_oxide and verible (Verilog/SystemVerilog) here
        ensure_installed = { "pyright", "clangd", "ltex", "markdown_oxide", "verible" },
      })

      -- Format Verilog/SystemVerilog on save via verible-verilog-ls
      -- (backed by verible-verilog-format).
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "verilog", "systemverilog" },
        callback = function(ev)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = ev.buf,
            callback = function()
              vim.lsp.buf.format({ bufnr = ev.buf, async = false, timeout_ms = 2000 })
            end,
          })
        end,
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }), 
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          vim.keymap.set('n', '<leader>tg', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', '<leader>th', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>tj', vim.lsp.buf.references, opts)
          
          vim.keymap.set({ 'n', 'v' }, '<leader>xa', vim.lsp.buf.code_action, opts)

          -- Jump to the next diagnostic, then offer code actions for it.
          vim.keymap.set('n', '<leader>ca', function()
            if not vim.diagnostic.jump({ count = 1, wrap = true }) then
              vim.notify('No diagnostics in this buffer', vim.log.levels.INFO)
              return
            end
            vim.lsp.buf.code_action()
          end, vim.tbl_extend('force', opts, { desc = 'Next diagnostic + code action' }))
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
    tag = "v0.2.1",
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
