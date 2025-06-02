return {
  {
    "ficcdaf/ashen.nvim",
    tag = "*",
    name = "ashen",
    lazy = false,
    priority = 1000,
    opts = {
      plugins = {
        autoload = true,
        override = {},
      },
    },
    config = function(_, opts)
      -- Set up Ashen theme
      require("ashen").setup(opts)
    end,
  },
}
