return {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    version = "*",
    opts = {
        options = {
            mode = "buffers",
            numbers = "none",
            close_command = "bdelete! %d",
            right_mouse_command = "bdelete! %d",
            left_mouse_command = "buffer %d",
            middle_mouse_command = nil,
            indicator = {
                icon = '▎',
                style = 'icon',
            },
            --buffer_close_icon = '',
            modified_icon = '●',
            close_icon = '',
            left_trunc_marker = '',
            right_trunc_marker = '',
            max_name_length = 18,
            max_prefix_length = 15,
            tab_size = 18,
            diagnostics = false,
            diagnostics = "nvim_lsp",
            offsets = { { filetype = "NvimTree", text = "File Explorer", text_align = "center", padding = 1 } },
            show_buffer_icons = true,
            show_buffer_close_icons = true,
            show_close_icon = true,
            show_tab_indicators = true,
            persist_buffer_sort = true,
            separator_style = "thin", --  "slant", "thick" or "thin"
            enforce_regular_tabs = false,
            always_show_bufferline = true,
            sort_by = 'id',
            hover = {
                enabled = true,
                delay = 200,
                reveal = { 'close' }
            },
            custom_filter = function(buf_number)
                -- Funcao para ocultar buffers com '[No name]'
                local buf_name = vim.fn.bufname(buf_number)
                if buf_name == "" or buf_name == "[No name]" then
                    return false
                end
                return true
            end,
        },
    },
}
