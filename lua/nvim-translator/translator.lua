local M = {}
local async = require('lib.async')

--- Define specification of translate API{{{
--- The URL of translate api.
---@type string
M.URL_TRANSLATOR =
"https://script.google.com/macros/s/AKfycbz3W9G4Jm4GFF_R74CsgsOOQJvDCw2kXIUecRQEx9uHJ56xjH9gLyoVDcsYJ198hjE/exec"
--v1.0 "https://script.google.com/macros/s/AKfycbwazxusB41dZgqxLMuQ1mn6177dGGISodFDv4-yaeKuTr45BaDXqOAupIiceJyBCEs/exec"

--- Request paramaters of translate api.
---@class RequestParamKey
---@field src string
---@field dst string
---@field txt string
M.REQUEST_PARAM_KEY = {
    src = "source",
    dst = "target",
    txt = "text"
}

---maximum translatable text length 
---@type integer
M.TEXT_LEN_LIMIT = 3000
-- }}}

-- text loader {{{
-- load text selected on visual mode
---@type fun(): string
local load_visual_text = function()
    local zreg_bf = vim.fn.getreg("z")
    vim.cmd('noautocmd normal! "zy')
    local zreg_af = vim.fn.getreg("z")
    vim.fn.setreg("z", zreg_bf)
    return zreg_af
end

-- load text under cursor
---@type fun(): string
local load_cursor_text = function()
    local zreg_bf = vim.fn.getreg("z")
    vim.cmd('noautocmd normal! viw"zy')
    local zreg_af = vim.fn.getreg("z")
    vim.fn.setreg("z", zreg_bf)
    return zreg_af
end

local text_loaders = {
    visual = load_visual_text,
    cursor = load_cursor_text
}
---@param type "visual"|"cursor"
---@return string
M.load_text = function(type)
    local text_loader = text_loaders[type]
    local text = text_loader()
    return text
end
-- }}}

--- Create reqest paramater to hit the translate API{{{
---@type fun(text: string, src: LANG, dst: LANG): string?
M.create_req_params = function(text, src, dst)
    -- source text must be less than 3000 characters
    if string.len(text) > M.TEXT_LEN_LIMIT then
        vim.notify("the text must be less than 3,000 characters", vim.log.levels.WARN)
        return nil
    end

    -- format text used in request parameter
    local req_text = text
    -- substitute characters that can't use in url
    local forbidden_chars = {
        "%s+", "!", '"', "#", "%$",
        -- "%",
        "&", "'", "%(", "%)", "*",
        "+", ",", "/", ":", ";",
        "<", "=", ">", "?", "@",
        "%[", "%]",
        -- "^",
        "`", "%{", "%|", "%}", "~",
    }
    local url_encodes = {
        "%%20", "%%21", "%%22", "%%23", "%%24",
        -- "%%25",
        "%%26", "%%27", "%%28", "%%29", "%%2A",
        "%%2B", "%%2C", "%%2F", "%%3A", "%%3B",
        "%%3C", "%%3D", "%%3E", "%%3F", "%%40",
        "%%5B", "%%5D",
        -- "%%5E",
        "%%60", "%%7B", "%%7C", "%%7D", "%%7E",
    }
    for i = 1, #forbidden_chars do
        req_text = string.gsub(req_text, forbidden_chars[i], url_encodes[i])
    end
    -- create reqest paramater
    local req_params = ""
    req_params = req_params .. "?" .. M.REQUEST_PARAM_KEY.txt .. "=" .. req_text
    req_params = req_params .. "&" .. M.REQUEST_PARAM_KEY.src .. "=" .. src
    req_params = req_params .. "&" .. M.REQUEST_PARAM_KEY.dst .. "=" .. dst

    return req_params
end
-- }}}

---@param text string
---@param src LANG
---@param dst LANG
---@param on_success function
---@param on_err function
M.translate = function(text, src, dst, on_success, on_err)
    local cmd = "curl"
    local url = M.URL_TRANSLATOR .. M.create_req_params(text, src, dst)
    local cmd_args = {
        "-sS",
        "-L",
        url
    }
    async.execute_cmd_async(cmd, cmd_args, on_success, on_err)
end

return M
