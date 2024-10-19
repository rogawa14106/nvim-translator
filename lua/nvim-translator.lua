local M = {}

-- import modules
local nt_config = require('nvim-translator.config')
local translator = require('nvim-translator.translator')
local async = require('lib.async')
local ui = require('nvim-translator.ui')

---@param src LANG
---@param dst LANG
local translate = function(text, src, dst)
    -- open floating window
    ui.new()

    -- draw spinner to notify user now wating
    local spinner = ui.draw_spinner({ "◐ now translating...", "☻ now translating...", "◑ now translating...", "◎ now translating..." }, 1.5)

    -- translate text asynchronously(stop spinner in callback function on_success)
    local cmd = "curl"
    local cmd_args = {
        "-L",
        translator.URL_TRANSLATOR .. translator.create_req_params(text, src, dst),
    }
    local on_exit = function(data)
        print(data)
        if spinner ~= nil then
            spinner:close()
        end
        -- ui.resize()
        -- TODO resize window size
        ui.overwrite_lines({ data })
    end
    local on_err = function(_)--data)
        return nil
    end
    async.execute_cmd_async(cmd, cmd_args, on_exit, on_err)
end

-- initialize nvim-translator
---@type fun(user_config: NTConfig): nil
function M.setup(user_config)
    -- override default nvim-translator configuration
    -- local config = nt_config.build_config(user_config)
    local keymaps = user_config.keymap

    for i = 1, #keymaps do
        print('nvim-translator setup called')
        vim.api.nvim_set_keymap("v", keymaps[i].key, "", {
            callback = function()
                local text = translator.load_text("visual")
                translate(text, keymaps[i].src, keymaps[i].dst)
            end,
        })
    end
end

return M
