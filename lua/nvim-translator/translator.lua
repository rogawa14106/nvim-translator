local M = {}

--- Define translate api specification{{{
--- The URL of translate api.
---@type string
local URL_TRANSLATOR =
"https://script.google.com/macros/s/AKfycbwazxusB41dZgqxLMuQ1mn6177dGGISodFDv4-yaeKuTr45BaDXqOAupIiceJyBCEs/exec"

--- Request paramaters of translate api.
---@class RequestParamKey
local REQUEST_PARAM_KEY = {
    src = "source",
    dst = "target",
    txt = "text"
}
-- }}}
---
--- Create reqest paramater to hit the translate API{{{
---@type fun(text: string, src: LANG, dst: LANG): string?
local create_req_params = function(text, src, dst)
    -- source text must be less than 3000 characters
    local strlen_max = 3000
    if string.len(text) > strlen_max then
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
    req_params = req_params .. "?" .. REQUEST_PARAM_KEY.txt .. "=" .. req_text
    req_params = req_params .. "&" .. REQUEST_PARAM_KEY.src .. "=" .. src
    req_params = req_params .. "&" .. REQUEST_PARAM_KEY.dst .. "=" .. dst

    return req_params
end
-- }}}
--
-- Hit the translation API{{{
---@type fun(text: string, src: LANG, dst: LANG): string?
local hit_translation_api = function(text, src, dst)
    if vim.fn.executable('curl') ~= 1 then
        vim.notify("curl is required to translation", vim.log.levels.ERROR)
        return nil
    end
    -- assemble cmd to hit the API
    local req_url = URL_TRANSLATOR                       -- http://<translation api url>
    local req_params = create_req_params(text, src, dst) -- ?text=.....&source=..&target=..
    if req_params == "" then
        vim.notify("failed to build reqest paramater to hit the tralslate api", vim.log.levels.ERROR)
        return nil
    end
    local req = '"' .. req_url .. req_params .. '"'
    local cmd_curl = 'curl -L ' .. req
    local cmd_rm_stderr = ''
    if vim.fn.has('win32') == 1 then
        cmd_rm_stderr = '2> nul'
    else
        cmd_rm_stderr = '2> /dev/null'
    end
    local cmd = cmd_curl .. ' ' .. cmd_rm_stderr

    -- Hit the translation api and read translate result(stdout)
    local handle = io.popen(cmd)
    if handle == nil then
        vim.notify("failed to open proccess handler", vim.log.levels.ERROR)
        return nil
    end
    local res = handle:read('*a')
    handle:close()

    if res == nil then
        vim.notify("failed to translate text", vim.log.levels.ERROR)
        return nil
    end
    return res
end
-- }}}
--
-- translate text{{{
---@type fun(text: string, src: LANG, dst: LANG): string?
M.translate = function(text, src, dst)
    local translated_text = hit_translation_api(text, src, dst)
    if translated_text == nil then
        -- if response was empty, print error
        vim.notify("failed to translate text.", vim.log.levels.ERROR)
        return nil
    end
    return translated_text
end
-- }}}

return M
