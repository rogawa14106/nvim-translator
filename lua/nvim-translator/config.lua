local M = {}

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
            src = "ja",
            dst = "en",
            key = "<Leader>g?",
        }
    },
}

---@param user_config NTConfig
---@return boolean is_valid
---@return string err
local validate_config = function(user_config)
    local is_valid = true
    local err = "nvim-translator: invalid userconfig."

    -- check keymap configuration
    for i = 1, #user_config.keymap do
        if user_config.keymap[i] == nil then
            is_valid = false
            err = err .. " nil value not allowed on keymap configuration."
            break
        end
    end

    if is_valid == true then
        return true, ""
    else
        return false, err
    end
end

---function to build configuration
---@type fun(user_config: NTConfig?): NTConfig
function M.build_config(user_config)
    -- return default config when user config is nil
    if user_config == nil then
        return default_config
    end
    -- validate user configuration
    local is_valid_config, err = validate_config(user_config)
    if is_valid_config == false then
        vim.notify(err, vim.log.levels.WARN)
        return default_config
    end

    return user_config
end

return M
