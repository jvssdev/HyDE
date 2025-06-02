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

local theme_file = vim.fn.expand("~/.config/hypr/themes/wallbash.conf")

-- Function to extract the value of $HYDE_THEME or apply fallback
local function get_theme_value(path)
  local file = io.open(path, "r")
  if not file then
    -- Fallback: file not found, apply default colorscheme
    vim.cmd("colorscheme catppuccin")
    return nil
  end

  for line in file:lines() do
    -- Match the line that defines $HYDE_THEME
    local theme = line:match("^%$HYDE_THEME=(.+)")
    if theme then
      file:close()
      return vim.trim(theme)
    end
  end

  file:close()
  -- Fallback: $HYDE_THEME not found in the file
  vim.cmd("colorscheme catppuccin")
  return nil
end

-- Get the theme value (or apply fallback if not found)
local theme_name = get_theme_value(theme_file)

-- Apply colorscheme if a valid theme was found
if theme_name then
  if theme_name == "Tokyo Night" then
    vim.cmd("colorscheme tokyonight")
  elseif theme_name == "Decay Green" then
    vim.cmd("colorscheme gruvbox-material")
  elseif theme_name == "Gruvbox Retro" then
    vim.cmd("colorscheme gruvbox")
  elseif theme_name == "Catppuccin Mocha" then
    vim.cmd("colorscheme catppuccin-mocha")
  elseif theme_name == "Catppuccin Latte" then
    vim.cmd("colorscheme catppuccin-latte")
  elseif theme_name == "Synth Wave" then
    vim.cmd("colorscheme fluoromachine")
  elseif theme_name == "Green Lush" then
    vim.cmd("colorscheme everforest")
  elseif theme_name == "Nordic Blue" then
    vim.cmd("colorscheme nord")
  elseif theme_name == "Graphite Mono" then
    vim.cmd("colorscheme quiet")
  elseif theme_name == "Frosted Glass" then
    vim.cmd("colorscheme tokyonight-day")
  elseif theme_name == "Rosé Pine" then
    vim.cmd("colorscheme rose-pine")
  elseif theme_name == "Red Stone" then
    vim.cmd("colorscheme ashen")
  else
    -- Fallback if theme is not recognized
    vim.cmd("colorscheme catppuccin")
  end
end
