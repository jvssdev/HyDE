return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "[F]ormat buffer",
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { { "prettierd", "prettier" } },
        typescript = { { "prettierd", "prettier" } },
        javascriptreact = { { "prettierd", "prettier" } },
        typescriptreact = { { "prettierd", "prettier" } },
        html = { "htmlbeautifier" },
        json = { { "prettierd", "prettier" } },
        astro = { { "prettierd", "prettier" } },
        markdown = { { "prettierd", "prettier" } },
        go = { "gofmt" },
      },
      formatters = {
        stylua = {
          prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
        },
        prettier = {
          prepend_args = { "--tab-width", "2" },
        },
        prettierd = {
          env = {
            PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/.prettierrc"),
          },
        },
        isort = {
          prepend_args = { "--line-length", "88", "--profile", "black" },
        },
        black = {
          prepend_args = { "--line-length", "88" },
        },
        htmlbeautifier = {
          prepend_args = { "--indent-size", "2" },
        },
      },
    },
  },
}
