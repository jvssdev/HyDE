return {
  {
    "shaunsingh/nord.nvim",
    lazy = false,
    name = "nord",
    priority = 1000,
    init = function()
      -- Example config in lua
      vim.g.nord_contrast = true
      vim.g.nord_borders = false
      vim.g.nord_disable_background = false
      vim.g.nord_italic = false
      vim.g.nord_uniform_diff_background = true
      vim.g.nord_bold = false
    end,
  },
}
