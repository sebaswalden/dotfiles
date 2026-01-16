return {
  -- Mason (LSP installer)
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- Mason LSPConfig bridge (for auto-installing LSP servers)
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "eslint",
          "lua_ls",
          "rust_analyzer",
          "svelte",
          "ts_ls",
          "tailwindcss",
          "html",
          "ruby_lsp",
        },
      })
    end,
  },

  -- Mason Tool Installer (for formatters/linters not managed by mason-lspconfig)
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "prettierd",
        },
        run_on_start = true,
      })
    end,
  },

  -- LSP Configuration using native vim.lsp.config (Neovim 0.11+)
  {
    "hrsh7th/cmp-nvim-lsp",
    config = function()
      local cmp_lsp = require("cmp_nvim_lsp")
      local capabilities = cmp_lsp.default_capabilities()

      -- Helper function to copy diagnostics to clipboard
      local function copy_diagnostics_to_clipboard()
        local diagnostics = vim.diagnostic.get()
        local diagnostic_text = {}
        for _, diagnostic in ipairs(diagnostics) do
          table.insert(diagnostic_text, diagnostic.message)
        end
        local text = table.concat(diagnostic_text, "\n")
        vim.fn.setreg("+", text)
      end

      -- LSP keybindings on attach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local opts = { buffer = bufnr, remap = false }

          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
          vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
          vim.keymap.set("n", "<leader>gl", copy_diagnostics_to_clipboard, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
          vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
        end,
      })

      -- Configure LSP servers using vim.lsp.config (Neovim 0.11+)
      vim.lsp.config("lua_ls", {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      vim.lsp.config("eslint", {
        cmd = { "vscode-eslint-language-server", "--stdio" },
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
        root_markers = {
          ".eslintrc",
          ".eslintrc.js",
          ".eslintrc.cjs",
          ".eslintrc.json",
          ".eslintrc.yaml",
          ".eslintrc.yml",
          "eslint.config.js",
          "eslint.config.mjs",
          "eslint.config.cjs",
          "package.json",
          ".git",
        },
        capabilities = capabilities,
        before_init = function(_, config)
          local root_dir = config.root_dir
          if root_dir then
            config.settings = config.settings or {}
            config.settings.workspaceFolder = {
              uri = root_dir,
              name = vim.fn.fnamemodify(root_dir, ":t"),
            }
          end
        end,
        settings = {
          validate = "on",
          useESLintClass = false,
          experimental = {
            useFlatConfig = false,
          },
          codeActionOnSave = {
            enable = false,
            mode = "all",
          },
          format = true,
          quiet = false,
          onIgnoredFiles = "off",
          rulesCustomizations = {},
          run = "onType",
          problems = {
            shortenToSingleLine = false,
          },
          nodePath = "",
          workingDirectory = { mode = "auto" },
          codeAction = {
            disableRuleComment = {
              enable = true,
              location = "separateLine",
            },
            showDocumentation = {
              enable = true,
            },
          },
        },
        handlers = {
          ["eslint/openDoc"] = function(_, result)
            if result then
              vim.ui.open(result.url)
            end
            return {}
          end,
          ["eslint/confirmESLintExecution"] = function()
            return 4 -- approved
          end,
          ["eslint/probeFailed"] = function()
            vim.notify("[lsp] ESLint probe failed.", vim.log.levels.WARN)
            return {}
          end,
          ["eslint/noLibrary"] = function()
            vim.notify("[lsp] Unable to find ESLint library.", vim.log.levels.WARN)
            return {}
          end,
        },
      })

      vim.lsp.config("rust_analyzer", {
        cmd = { "rust-analyzer" },
        filetypes = { "rust" },
        root_markers = { "Cargo.toml", ".git" },
        capabilities = capabilities,
      })

      vim.lsp.config("svelte", {
        cmd = { "svelteserver", "--stdio" },
        filetypes = { "svelte" },
        root_markers = { "package.json", ".git" },
        capabilities = capabilities,
      })

      vim.lsp.config("ts_ls", {
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
        capabilities = capabilities,
      })

      vim.lsp.config("tailwindcss", {
        cmd = { "tailwindcss-language-server", "--stdio" },
        filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "svelte" },
        root_markers = { "tailwind.config.js", "tailwind.config.ts", "postcss.config.js", "package.json", ".git" },
        capabilities = capabilities,
      })

      vim.lsp.config("html", {
        cmd = { "vscode-html-language-server", "--stdio" },
        filetypes = { "html" },
        root_markers = { "package.json", ".git" },
        capabilities = capabilities,
        init_options = {
          provideFormatter = false,
        },
      })

      vim.lsp.config("ruby_lsp", {
        cmd = { "ruby-lsp" },
        filetypes = { "ruby" },
        root_markers = { "Gemfile", ".git" },
        capabilities = capabilities,
      })

      -- Enable LSP servers
      vim.lsp.enable({ "lua_ls", "eslint", "rust_analyzer", "svelte", "ts_ls", "tailwindcss", "html", "ruby_lsp" })

      -- Diagnostic configuration
      vim.diagnostic.config({
        virtual_text = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "E",
            [vim.diagnostic.severity.WARN] = "W",
            [vim.diagnostic.severity.HINT] = "H",
            [vim.diagnostic.severity.INFO] = "I",
          },
        },
      })
    end,
  },
}
