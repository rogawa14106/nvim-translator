local M = {}

local URL_TRANSLATOR =
"https://script.google.com/macros/s/AKfycbwazxusB41dZgqxLMuQ1mn6177dGGISodFDv4-yaeKuTr45BaDXqOAupIiceJyBCEs/exec"

---{{{ create reqest paramater
local create_req_params = function(text, src, dst)
    -- source text must be less than 3000 characters
    local strlen_max = 3000
    if string.len(text) > strlen_max then
        vim.notify("the text must be less than 3,000 characters", vim.log.levels.WARN)
        return ""
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
    local req_params = "?text=" .. req_text .. "&source=" .. src .. "&target=" .. dst
    return req_params
end
-- }}}
--
-- hit the translation API{{{
local hit_translation_api = function(src, dst, text)
    if vim.fn.executable('curl') ~= 1 then
        vim.notify("curl is required to translation", vim.log.levels.ERROR)
        return nil
    end
    -- assemble cmd to hit the api
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

    -- hit the translation api and read translate result(stdout)
    local handle = io.popen(cmd)
    if handle == nil then return end
    local res = handle:read('*a')
    handle:close()

    if res == nil then
        vim.notify("failed to translate text", vim.log.levels.ERROR)
        return nil
    else
        return res
    end
end
-- }}}
--
-- translate text{{{
---@type fun(src: LANG, dst: LANG, text: string): string?
M.translate = function(src, dst, text)
    local translated_text = hit_translation_api(src, dst, text)
    if translated_text == nil then
        -- if response was empty, print error
        vim.notify("failed to translate text.", vim.log.levels.ERROR)
        return nil
    end
    return translated_text
end
-- }}}

return M
