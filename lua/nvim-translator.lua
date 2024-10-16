local M = {}

local nt_config = require('nvim-translator.config')

---@type fun(user_config: NTConfig): nil
function M.setup(user_config)
    -- override default nvim-translator configuration
    local config = nt_config.build_config(user_config)
end

function M.init()
    print('hello nvim-translator')
end

return M
