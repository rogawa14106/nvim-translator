local M = {}

-- import modules
local ui = require('nvim-translator.ui')

---nvim-translator configuration type
---@class NTConfig
---@field keymap NTKeymapConfig[]
--@field ui NTUIConfig

-- keymap configuration type
---@class NTKeymapConfig
---@field src LANG
---@field dst LANG
---@field key string

-- define nvim-translator ui configuration type
--@class NTUIConfig
--@field border BORDER_TYPE

---@alias LANG @string literal to specify translate language
---| "ja" japanese
---| "en" english


---default configuration of nvim-translator
---@type NTConfig
local default_config = {
    keymap = {
        {
            src = "en",
            dst = "ja",
            key = "<Leader>?",
        },
        {
            src = "en",
            dst = "ja",
            key = "<Leader>g?",
        }
    },
    ui = {
        border = ui.border_type.SOLID
    },
}

---@type fun(user_config: NTConfig): boolean
local validate_config = function(user_config)
    -- TODO impl validation
    return true
end

---function to build configuration
---@type fun(user_config: NTConfig): nil
function M.build_config(user_config)
    -- validate user configuration
    local is_valid_config = validate_config(user_config)
    if is_valid_config ~= true then
        vim.notify("", vim.log.levels.ERROR)
    end

    -- define configuration of default
    local config = default_config

    ---for users to override default configurations.
    if user_config.keymap ~= nil then
        config.keymap = user_config.keymap
    end
    -- if user_config.ui ~= nil then
        -- config.ui = user_config.ui
    -- end
    return config
end

return M
