local prefix = "<leader>o"

return {
  {
    -- "epwalsh/obsidian.nvim",
    "obsidian-nvim/obsidian.nvim", -- NOTE: Using a fork from the community
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-telescope/telescope.nvim",
      "nvim-treesitter/nvim-treesitter",
      "MeanderingProgrammer/render-markdown.nvim",
    },
    keys = {
      { prefix .. "o",       "<cmd>ObsidianOpen<CR>",        desc = "Open in Obsidian App" },
      { prefix .. "s",       "<cmd>ObsidianSearch<CR>",      desc = "Obsidian Search" },
      { prefix .. "n",       "<cmd>ObsidianNew<CR>",         desc = "Obsidian New Note" },
      { prefix .. "<space>", "<cmd>ObsidianQuickSwitch<CR>", desc = "Obsidian Find Files" },
      { prefix .. "b",       "<cmd>ObsidianBacklinks<CR>",   desc = "Obsidian Backlinks" },
      { prefix .. "t",       "<cmd>ObsidianTemplate<CR>",    desc = "Obsidian Template" },
      { prefix .. "L",       "<cmd>ObsidianLink<CR>",        mode = "v",                   desc = "Obsidian Link" },
      { prefix .. "l",       "<cmd>ObsidianLinks<CR>",       desc = "Obsidian Links" },
      -- { prefix .. "l", "<cmd>ObsidianLinkNew<CR>", mode = "v", desc = "Obsidian New Link" },
      { prefix .. "e",       "<cmd>ObsidianExtractNote<CR>", mode = "v",                   desc = "Obsidian Extract Note" },
      { prefix .. "w",       "<cmd>ObsidianWorkspace<CR>",   desc = "Obsidian Workspace" },
      { prefix .. "r",       "<cmd>ObsidianRename<CR>",      desc = "Obsidian Rename" },
      { prefix .. "i",       "<cmd>ObsidianPasteImg<CR>",    desc = "Obsidian Paste Image" },
      { prefix .. "d",       "<cmd>ObsidianDailies<CR>",     desc = "Obsidian Daily Notes" },
    },
    opts = {
      workspaces = {
        {
          name = "Obsidian Vault",
          path = "~/Documents/Obsidian Vault",
        },
      },
      --
      -- notes_subdir = "01 - Bandeja Entrada",
      --
      -- daily_notes = {
      --   folder = "03 - Diario/Diariamente",
      --   date_format = "%Y-%m-%d",
      --   alias_format = "%B %-d, %Y",
      --   template = "00 - Data/Plantillas/Diariamente.md",
      -- },

      completion = {
        nvim_cmp = false,
        blink = true,
      },

      -- picker = {
      --   name = "snacks.pick",
      --   note_mappings = {
      --     -- Create a new note from your query.
      --     new = "<C-x>",
      --     -- Insert a link to the selected note.
      --     insert_link = "<C-l>",
      --   },
      --   tag_mappings = {
      --     -- Add tag(s) to current note.
      --     tag_note = "<C-x>",
      --     -- Insert a tag at the current location.
      --     insert_tag = "<C-l>",
      --   },
      -- },

      mappings = {
        ["gf"] = {
          action = function()
            return require("obsidian").util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
        ["<C-c>"] = {
          action = function()
            return require("obsidian").util.toggle_checkbox()
          end,
          opts = { buffer = true },
        },
        ["<cr>"] = {
          action = function()
            return require("obsidian").util.smart_action()
          end,
          opts = { buffer = true, expr = true },
        },
      },

      -- new_notes_location = "notes_subdir",

      -- templates = {
      --   subdir = "00 - Data/Plantillas",
      --   date_format = "%Y-%m-%d-%a",
      --   time_format = "%H:%M",
      -- },

      ---@param spec { id: string, dir: obsidian.Path, title: string|? }
      ---@return string|obsidian.Path The full path to the new note.
      note_path_func = function(spec)
        return spec.title
      end,

      note_frontmatter_func = function(note)
        if note.title then
          note:add_alias(note.title)
        end

        local out = { aliases = note.aliases }

        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end

        return out
      end,

      follow_url_func = function(url)
        vim.fn.jobstart({ "xdg-open", url })
      end,

      -- attachments = {
      --   img_folder = "00 - Data/Documentos",
      -- },

      ui = { enable = true },

      statusline = {
        enabled = true,
        format = "{{backlinks}} backlinks | {{words}} words",
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { prefix, group = "obsidian", icon = " ", mode = { "n", "v" } },
      },
    },
  },
  -- {
  --   "nvim-lualine/lualine.nvim",
  --   optional = true,
  --   opts = function(_, opts)
  --     table.insert(opts.sections.lualine_x, 1, "g:obsidian")
  --   end,
  -- },
}
