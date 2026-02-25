return {
  "vimpostor/vim-lumen",
  lazy = false,
  priority = 1001, -- Higher than catppuccin to ensure it can trigger the change
  init = function()
    -- Set the colorschemes for Lumen
    -- These must be set in 'init' so they are available when the plugin loads
    vim.g.lumen_light_colorscheme = "catppuccin-latte"
    vim.g.lumen_dark_colorscheme = "catppuccin-frappe"
  end,
}
