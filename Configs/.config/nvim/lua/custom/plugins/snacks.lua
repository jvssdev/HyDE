return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = false },
      dashboard = { enabled = true },
      explorer = { enabled = false },
      indent = { enabled = false },
      input = { enabled = false },
      picker = { enabled = false },
      notifier = { enabled = false },
      quickfile = { enabled = false },
      scope = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
      words = { enabled = false },
      lazygit = {
        -- your lazygit configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
      image = {
        formats = {
          "png",
          "jpg",
          "jpeg",
          "gif",
          "bmp",
          "webp",
          "tiff",
          "heic",
          "avif",
          "mp4",
          "mov",
          "avi",
          "mkv",
          "webm",
          "pdf",
        },
        force = false, -- try displaying the image, even if the terminal does not support it
        doc = {
          enabled = true,
          inline = true,
          float = true,
          max_width = 80,
          max_height = 40,
          conceal = function(lang, type)
            return type == "math"
          end,
        },
        img_dirs = { "img", "images", "assets", "static", "public", "media", "attachments" },
        wo = {
          wrap = false,
          number = false,
          relativenumber = false,
          cursorcolumn = false,
          signcolumn = "no",
          foldcolumn = "0",
          list = false,
          spell = false,
          statuscolumn = "",
        },
        cache = vim.fn.stdpath("cache") .. "/snacks/image",
        debug = {
          request = false,
          convert = false,
          placement = false,
        },
        env = {},
        icons = {
          math = "󰪚 ",
          chart = "󰄧 ",
          image = " ",
        },
        convert = {
          notify = true,
          magick = {
            default = { "{src}[0]", "-scale", "1920x1080>" },
            vector = { "-density", 192, "{src}[0]" },
            math = { "-density", 192, "{src}[0]", "-trim" },
            pdf = { "-density", 192, "{src}[0]", "-background", "white", "-alpha", "remove", "-trim" },
          },
        },
        math = {
          enabled = true,
          typst = {
            tpl = [[
#set page(width: auto, height: auto, margin: (x: 2pt, y: 2pt))
#show math.equation.where(block: false): set text(top-edge: "bounds", bottom-edge: "bounds")
#set text(size: 12pt, fill: rgb("${color}"))
${header}
${content}]],
          },
          latex = {
            font_size = "Large",
            packages = { "amsmath", "amssymb", "amsfonts", "amscd", "mathtools" },
            tpl = [[
\documentclass[preview,border=0pt,varwidth,12pt]{standalone}
\usepackage{${packages}}
\begin{document}
${header}
{ \${font_size} \selectfont
  \color[HTML]{${color}}
${content}}
\end{document}]],
          },
        },
      },
    },
    keys = {
      {
        "<leader>lg",
        function()
          require("snacks").lazygit()
        end,
        desc = "Lazygit",
      },
    },
  },
}
