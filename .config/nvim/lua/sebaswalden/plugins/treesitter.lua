return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = function()
    -- Install parsers on plugin install/update only
    require("nvim-treesitter").install({
      "javascript", "typescript", "xml", "c", "lua", "vim", "vimdoc",
      "svelte", "css", "scss", "html", "tsx", "json"
    })
  end,
  config = function()
    require("nvim-treesitter").setup({})
  end,
}
