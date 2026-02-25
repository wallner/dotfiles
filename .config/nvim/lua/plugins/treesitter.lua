return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    ensure_installed = { 
      "lua", "vim", "vimdoc", "query", "go", "python", 
      "terraform", "dockerfile", "yaml", "json", "markdown" 
    },
    sync_install = false,
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
  },
  config = function(_, opts)
    -- Correct setup for modern nvim-treesitter versions
    require("nvim-treesitter").setup(opts)
  end,
}
