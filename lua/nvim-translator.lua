local M = {}

-- import modules
local nt_config = require('nvim-translator.config')
local translator = require('nvim-translator.translator')
local ui = require('nvim-translator.ui')

---@param text string
---@param src LANG
---@param dst LANG
local translate = function(text, src, dst)
    -- open floating window
    ui.new()
    vim.cmd('noautocmd normal! gg0')

    -- draw spinner to notify user now wating
    local spinner = ui.draw_spinner(
    { "◐ now translating.", "☻ now translating..", "◑ now translating...", "◎ now translating" }, 1.5)

    -- translate text asynchronously(stop spinner in callback function on_success)
    local on_success = function(data)
        if spinner ~= nil then
            spinner:close()
        end
        -- TODO resize window size
        -- ui.resize()
        local formatted_data = translator.format_text(dst, data)
        ui.overwrite_lines(formatted_data)
    end
    local on_err = function(data)
        if spinner ~= nil then
            spinner:close()
            vim.notify("falied to translation\n" .. data, vim.log.levels.WARN)
        end
    end
    translator.translate(text, src, dst, on_success, on_err)
end

-- usage
-- ``` lua
-- require('nvim-translator').setup({
--     keymap = {
--        {
--            src = "en",
--            dst = "ja",
--            key = "<Leader>?",
--        },
--        -- ...add custom keymaps
--     }
-- })
-- ```
---@param user_config NTConfig?
function M.setup(user_config)
    -- override default nvim-translator configuration
    local config = nt_config.build_config(user_config)
    local keymaps = config.keymap

    -- set keymap
    for i = 1, #keymaps do
        vim.api.nvim_set_keymap("v", keymaps[i].key, "", {
            callback = function()
                local text = translator.load_text("visual")
                translate(text, keymaps[i].src, keymaps[i].dst)
            end,
        })
    end
end

return M
