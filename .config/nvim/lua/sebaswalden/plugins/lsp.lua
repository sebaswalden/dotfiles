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
        },
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
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        root_markers = { ".eslintrc", ".eslintrc.js", ".eslintrc.json", "eslint.config.js", "package.json", ".git" },
        capabilities = capabilities,
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

      -- Enable LSP servers
      vim.lsp.enable({ "lua_ls", "eslint", "rust_analyzer", "svelte" })

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
