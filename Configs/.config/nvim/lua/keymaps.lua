local map = vim.keymap.set

local function bufremove()
  if vim.fn.winnr("$") > 1 then
    vim.cmd("bdelete")
  else
    vim.cmd("bd")
  end
end

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear Search Highlight" })

-- Diagnostic keymaps
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- TIP: Disable arrow keys in normal mode
-- map('n', '<left>', '<cmd>echo "Use h to move!!"<CR>', { desc = 'Disable left arrow key' })
-- map('n', '<right>', '<cmd>echo "Use l to move!!"<CR>', { desc = 'Disable right arrow key' })
-- map('n', '<up>', '<cmd>echo "Use k to move!!"<CR>', { desc = 'Disable up arrow key' })
-- map('n', '<down>', '<cmd>echo "Use j to move!!"<CR>', { desc = 'Disable down arrow key' })

-- Keybinds to make split navigation easier.
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

map("n", "<leader>bd", function()
  if vim.bo.buftype == "terminal" then
    vim.cmd("bdelete!")
  else
    vim.cmd("bdelete")
  end
end, { desc = "Delete Buffer" })

map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-- File Explorer
map("n", "<leader>e", function()
  local ft = vim.bo.filetype
  if ft == "neo-tree" then
    vim.cmd("Neotree toggle")
  else
    vim.cmd("Neotree focus")
  end
end, { desc = "File Explorer" })

map("n", "<leader>t", function()
  vim.cmd("tabnew | terminal")
end, { desc = "Open terminal in a new tab" })
