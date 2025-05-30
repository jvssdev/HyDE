return {
  {
    "datsfilipe/vesper.nvim",
    lazy = false,
    name = "vesper",
    enable = true,
    priority = 1000,
    opts = {
      transparent = true,
      italics = {
        comments = false,
        keywords = false,
        functions = false,
        strings = false,
        variables = false,
      },
    },
  },
}
