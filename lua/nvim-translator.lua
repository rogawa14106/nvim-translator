local M = {}

-- import modules
local nt_config = require('nvim-translator.config')

-- initialize nvim-translator
---@type fun(user_config: NTConfig): nil
function M.setup(user_config)
    -- override default nvim-translator configuration
    -- local config = nt_config.build_config(user_config)
    local main = require('nvim-translator.main')
    vim.api.nvim_set_keymap("n", "<Leader>?", "", {
        callback = function()
            main.init()
        end,
    })
end

return M
