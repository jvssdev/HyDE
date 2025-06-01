-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal vim.g.have_nerd_font = true

-- [[ Setting options ]]
require("options")

-- [[ Basic Keymaps ]]
require("keymaps")

-- [[ Install `lazy.nvim` plugin manager ]]
require("lazy-bootstrap")

-- [[ Configure and install plugins ]]
require("lazy-plugins")

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

vim.filetype.add({
  extension = {
    astro = "astro",
  },
})
vim.opt.fillchars = { eob = " " }

-- disable defaults
local default_providers = {
  "node",
  "perl",
  "python3",
  "ruby",
}
for _, provider in ipairs(default_providers) do
  vim.g["loaded_" .. provider .. "_provider"] = 0
end

-- Set different shiftwidth values for different file types
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua" },
  callback = function()
    vim.opt.shiftwidth = 2 -- Set shiftwidth to 2 for Lua
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    vim.opt.shiftwidth = 4 -- Set shiftwidth to 4 for Python
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript" },
  callback = function()
    vim.opt.shiftwidth = 2 -- Set shiftwidth to 2 for JavaScript and TypeScript
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "java" },
  callback = function()
    vim.opt.shiftwidth = 4 -- Set shiftwidth to 4 for Java
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = function()
    vim.opt.shiftwidth = 4 -- Set shiftwidth to 4 for Go
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "svelte" },
  callback = function()
    vim.opt.shiftwidth = 2 -- Set shiftwidth to 2 for Svelte
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "nix" },
  callback = function()
    vim.opt.shiftwidth = 2 -- Set shiftwidth to 2 for Nix
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "zig" },
  callback = function()
    vim.opt.shiftwidth = 4 -- Set shiftwidth to 4 for Zig
  end,
})

vim.filetype.add({
  extension = {
    astro = "astro",
  },
})

local is_wsl = vim.fn.has("wsl") == 1
-- WSL Clipboard support
if is_wsl then
  -- This is NeoVim's recommended way to solve clipboard sharing if you use WSL
  -- See: https://github.com/neovim/neovim/wiki/FAQ#how-to-use-the-windows-clipboard-from-wsl
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = 0,
  }
end

vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

--vim.cmd([[colorscheme catppuccin]])
--
--

--local wallbash_path = vim.fn.stdpath("config") .. "/lua/custom/plugins/wallbash.vim"

--local wayland = os.getenv("XDG_SESSION_TYPE") == "wayland"
--local hyprland = os.getenv("XDG_CURRENT_DESKTOP") == "Hyprland"

--if wayland and hyprland then
-- if vim.fn.filereadable(wallbash_path) == 1 then
-- vim.cmd("colorscheme wallbash")
-- end
--else
--vim.cmd("colorscheme catppuccin")
--end
--
--
vim.cmd("colorscheme catppuccin")
