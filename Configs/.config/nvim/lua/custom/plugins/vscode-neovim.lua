if not vim.g.vscode then
  return {}
end

vim.g.mapleader = " "
local vscode = require("vscode-neovim")
local map = vim.keymap.set

-- Options
vim.o.spell = false
vim.opt.timeoutlen = 150 -- To show whichkey without delay
vim.notify = vscode.notify
vim.g.clipboard = vim.g.vscode_clipboard

local function vscode_action(cmd, opts)
  return function()
    vscode.action(cmd, opts)
  end
end

-- Add some vscode specific keymaps
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- view problems
    map("n", "<leader>q", vscode_action("workbench.actions.view.problems"))
    -- open file explorer

    -- Variável de estado
    _G.vscode_file_explorer_open = false

    map("n", "<leader>e", function()
      if _G.vscode_file_explorer_open then
        vscode.action("workbench.action.toggleSidebarVisibility")
        vim.defer_fn(function()
          vscode.action("workbench.action.focusActiveEditorGroup")
        end, 100)
        _G.vscode_file_explorer_open = false
      else
        vscode.action("workbench.view.explorer")
        vim.defer_fn(function()
          vscode.action("workbench.files.action.focusFilesExplorer")
        end, 300) -- tempo maior aqui
        _G.vscode_file_explorer_open = true
      end
    end, { desc = "Toggle File Explorer with Focus" })
    --map("n", "<leader>t", vscode_action("workbench.action.terminal.toggleTerminal"))
    map("n", "<leader>t", vscode_action("workbench.action.terminal.newWithCwd"))
    -- working with editors (buffers)
    -- map("n", "<leader>bb", function()
    --   vscode_action("workbench.action.quickOpenPreviousRecentlyUsedEditorInGroup")
    --   vscode_action("list.select")
    -- end)
    -- map("n", "<leader>bn", vscode_action("workbench.action.nextEditor"))
    -- map("n", "<leader>bu", vscode_action("workbench.action.reopenClosedEditor"))
    -- map("n", "<leader>bh", vscode_action("workbench.action.moveEditorToLeftGroup"))
    -- map("n", "<leader>bj", vscode_action("workbench.action.moveEditorToBelowGroup"))
    -- map("n", "<leader>bk", vscode_action("workbench.action.moveEditorToAboveGroup"))
    -- map("n", "<leader>bl", vscode_action("workbench.action.moveEditorToRightGroup"))
    -- map("n", "<leader>,", vscode_action("workbench.action.showAllEditors"))
    -- map("n", "<leader>bA", vscode_action("workbench.action.closeAllEditors"))
    -- map("n", "<leader>ba", vscode_action("workbench.action.lastEditorInGroup"))
    -- map("n", "<leader>bf", vscode_action("workbench.action.firstEditorInGroup"))
    -- map("n", "<Leader>bL", vscode_action("workbench.action.closeEditorsToTheLeft"))
    -- map("n", "<Leader>bR", vscode_action("workbench.action.closeEditorsToTheRight"))
    map("n", "H", vscode_action("workbench.action.previousEditorInGroup"))
    map("n", "L", vscode_action("workbench.action.nextEditorInGroup"))
    map("n", "<leader>bd", vscode_action("workbench.action.closeActiveEditor"))
    -- breakpoints
    map("n", "<leader>B", vscode_action("editor.debug.action.toggleBreakpoint"))
    -- windows
    map("n", "<leader>|", vscode_action("workbench.action.splitEditorRight"))
    map("n", "<leader>-", vscode_action("workbench.action.splitEditorDown"))
    -- LSP actions
    map("n", "<leader>ca", vscode_action("editor.action.codeAction"))
    map("n", "gd", vscode_action("editor.action.goToTypeDefinition"))
    map("n", "gr", vscode_action("editor.action.goToReferences"))
    map("n", "gi", vscode_action("editor.action.goToImplementation"))
    map("n", "K", vscode_action("editor.action.showHover"))
    map("n", "<leader>cr", vscode_action("editor.action.rename"))
    map("n", "<leader>co", vscode_action("editor.action.organizeImports"))
    map("n", "<leader>cf", vscode_action("editor.action.formatDocument"))
    map("n", "<leader>ss", vscode_action("workbench.action.gotoSymbol"))
    map("n", "<leader>sS", vscode_action("workbench.action.showAllSymbols"))
    -- refactor
    map("n", "<leader>cR", vscode_action("editor.action.refactor"))
    -- markdown preview
    map("n", "<leader>cp", vscode_action("markdown.showPreviewToSide"))
    -- zen mode
    map("n", "<leader>z", vscode_action("workbench.action.toggleZenMode"))
    -- comments
    map("n", "<leader>gc", vscode_action("editor.action.commentSelection"))
    -- git
    map("n", "<leader>gg", vscode_action("gitlens.views.home.focus"))
    map("n", "<leader>ub", vscode_action("gitlens.toggleFileBlame"))
    map("n", "]h", function()
      vscode_action("workbench.action.editor.nextChange")
      vscode_action("workbench.action.compareEditor.nextChange")
    end)
    map("n", "[h", function()
      vscode_action("workbench.action.editor.previousChange")
      vscode_action("workbench.action.compareEditor.previousChange")
    end)
    -- diagnostics
    map("n", "]d", vscode_action("editor.action.marker.next"))
    map("n", "[d", vscode_action("editor.action.marker.prev"))
    map("n", "<leader>sk", vscode_action("whichkey.show"))
    -- search
    map("n", "<leader><space>", "<cmd>Find<cr>")
    map("n", "<leader>ff", "<cmd>Find<cr>")
    map("n", "<leader>/", vscode_action("workbench.action.findInFiles"))
    map("n", "<leader>sg", vscode_action("workbench.action.findInFiles"))
    map("n", "<leader>sc", vscode_action("workbench.action.showCommands"))
    -- ui
    map("n", "<leader>uC", vscode_action("workbench.action.selectTheme"))

    map("n", "<leader>bd", vscode_action("workbench.action.closeActiveEditor"), { desc = "Close Active Editor" })

    map("n", "<leader>sf", vscode_action("workbench.action.quickOpen"), { desc = "Quick Open (Ctrl+P)" })
  end,
})
return {}
-- return {
--   { import = "lazyvim.plugins.extras.vscode" },
--   {
--     "LazyVim/LazyVim",
--     config = function(_, opts)
--       opts = opts or {}
--       -- disable the colorscheme
--       opts.colorscheme = function() end
--       require("lazyvim").setup(opts)
--     end,
--   },
--   {
--     "folke/flash.nvim",
--     init = function()
--       local palette = require("catppuccin.palettes").get_palette("macchiato")
--       local bg = palette.none
--       vim.api.nvim_set_hl(0, "FlashBackdrop", { fg = bg })
--       vim.api.nvim_set_hl(0, "FlashLabel", { fg = palette.green, bg = bg, bold = true })
--       vim.api.nvim_set_hl(0, "FlashMatch", { fg = palette.lavender, bg = bg })
--       vim.api.nvim_set_hl(0, "FlashCurrent", { fg = palette.peach, bg = bg })
--     end,
--   },
-- }
