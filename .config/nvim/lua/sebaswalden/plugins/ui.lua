return {
  -- Core dependencies
  { "nvim-lua/plenary.nvim" },
  { "MunifTanjim/nui.nvim" },

  -- Colorscheme
  {
    "tinted-theming/tinted-vim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme base16-default-dark")
    end,
  },

  -- Hybrid theme
  { "w0ng/vim-hybrid" },

  -- Icons
  { "nvim-tree/nvim-web-devicons" },

  -- Markdown rendering
  { "MeanderingProgrammer/render-markdown.nvim" },

  -- UI enhancements
  { "stevearc/dressing.nvim" },
  {
    "folke/snacks.nvim",
    config = function()
      require("snacks").setup({ input = {}, picker = {}, terminal = {} })
    end,
  },
}
