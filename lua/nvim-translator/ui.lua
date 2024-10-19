local FloatWindow = require('lib.float_window')

local M = {}

---@type FloatWindow
local float_window = FloatWindow()

---@type fun():nil
function M.new()
    -- floatwindow configuration
    local config_win = {
        focusable = true,
        --         focusable = false,
        width     = 10,
        height    = 1,
        --         col       = vim.opt.columns:get() - width - border_off - offset,
        --         row       = vim.opt.lines:get() - height - border_off - offset - 1,
        col       = 1,
        row       = 1,
        border    = 'solid',
        --         title     = "vim translation ",
        style     = 'minimal',
        relative  = "cursor",
        anchor    = "NW",
        --         relative  = "editor",
    }
    local config_keymaps = {
        {
            is_buf = true,
            mode = "n",
            lhs = "q",
            rhs = "",
            opts = {
                noremap = true,
                callback = function()
                    float_window.close_win()
                end,
            },
        },
        {
            is_buf = true,
            mode = "n",
            lhs = "j",
            rhs = "gj",
            opts = {
                noremap = true,
                --                     callback = false,
            },
        },
        {
            is_buf = true,
            mode = "n",
            lhs = "k",
            rhs = "gk",
            opts = {
                noremap = true,
                --                     callback = false,
            },
        },
    }
    local options = {
        win = {
            {
                name = "wrap",
                value = true,
            }
        },
        buf = {
        },
        hl = {
            {
                name = "NormalFloat",
                value = {
                    fg = "#fefefe",
                    bg = "#382c2c",
                }
            },
            {
                name = "FloatBorder",
                value = {
                    fg = "#fefefe",
                    bg = "#382c2c",
                }
            },
        },
    }
    local config = {
        id = "nvim-translator",
        window = config_win,
        keymaps = config_keymaps,
        option = options
    }

    float_window.new(config)
end

---@type fun(lines: string[]):nil
function M.overwrite_lines(lines)
    float_window.write_lines(0, -1, lines)
end

function M.add_keymap(keymaps)
end

function M.resize(row, col, width, height)
end

---@type fun(spinner: string[])
function M.draw_spinner(spinner)
end

return M
