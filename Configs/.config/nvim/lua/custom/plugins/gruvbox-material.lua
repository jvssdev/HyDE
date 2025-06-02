return {
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    init = function()
      -- Theme background settings
      vim.o.background = "dark" -- tells Neovim to use dark mode

      -- Gruvbox-material specific settings
      vim.g.gruvbox_material_background = "hard" -- soft | medium | hard
      vim.g.gruvbox_material_foreground = "material" -- material | mix | original
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_ui_contrast = "high"
    end,
  },
}
