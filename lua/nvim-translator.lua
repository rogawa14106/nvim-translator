local M = {}

-- import modules
local nt_config = require('nvim-translator.config')
local translator = require('nvim-translator.translator')

-- initialize plugin
local function init()
    print('hello nvim-translator')
    local translate = translator.translate
end

---@type fun(user_config: NTConfig): nil
function M.setup(user_config)
    -- override default nvim-translator configuration
    local config = nt_config.build_config(user_config)
    init()
end

return M
