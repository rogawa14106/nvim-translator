local M = {}
local async = require('lib.async')

-- Define specification of translate API{{{
--- The URL of translate api.{{{
---@type string
URL_TRANSLATOR =
"https://script.google.com/macros/s/AKfycbz3W9G4Jm4GFF_R74CsgsOOQJvDCw2kXIUecRQEx9uHJ56xjH9gLyoVDcsYJ198hjE/exec"
--v1.0 "https://script.google.com/macros/s/AKfycbwazxusB41dZgqxLMuQ1mn6177dGGISodFDv4-yaeKuTr45BaDXqOAupIiceJyBCEs/exec"
-- }}}
--- Request paramaters of translate api.{{{
---@class RequestParamKey
---@field src string
---@field dst string
---@field txt string
REQUEST_PARAM_KEY = {
    src = "source",
    dst = "target",
    txt = "text"
}
-- }}}
--- maximum translatable text length {{{
---@type integer
TEXT_LEN_LIMIT = 3000
-- }}}
--- Language types{{{
---@alias LANG @string literal to specify translate language
---| "af" Afrikaans
---| "sq" Albanian
---| "am" Amharic
---| "ar" Arabic
---| "hy" Armenian
---| "as" Assamese
---| "ay" Aymara
---| "az" Azerbaijani
---| "bm" Bambara
---| "eu" Basque
---| "be" Belarusian
---| "bn" Bengali
---| "bho" Bhojpuri
---| "bs" Bosnian
---| "bg" Bulgarian
---| "ca" Catalan
---| "ceb" Cebuano
---| "zh-CN" Chinese (Simplified) (BCP-47)
---| "zh-TW" Chinese (Traditional) (BCP-47)
---| "co" Corsican
---| "hr" Croatian
---| "cs" Czech
---| "da" Danish
---| "dv" Dhivehi
---| "doi" Dogri
---| "nl" Dutch
---| "en" English
---| "eo" Esperanto
---| "et" Estonian
---| "ee" Ewe
---| "fil" Filipino (Tagalog)
---| "fi" Finnish
---| "fr" French
---| "fy" Frisian
---| "gl" Galician
---| "ka" Georgian
---| "de" German
---| "el" Greek
---| "gn" Guarani
---| "gu" Gujarati
---| "ht" Haitian Creole
---| "ha" Hausa
---| "haw" Hawaiian
---| "he" Hebrew
---| "hi" Hindi
---| "hmn" Hmong
---| "hu" Hungarian
---| "is" Icelandic
---| "ig" Igbo
---| "ilo" Ilocano
---| "id" Indonesian
---| "ga" Irish
---| "it" Italian
---| "ja" Japanese
---| "jv" Javanese
---| "kn" Kannada
---| "kk" Kazakh
---| "km" Khmer
---| "rw" Kinyarwanda
---| "gom" Konkani
---| "ko" Korean
---| "kri" Krio
---| "ku" Kurdish
---| "ckb" Kurdish (Sorani)
---| "ky" Kyrgyz
---| "lo" Lao
---| "la" Latin
---| "lv" Latvian
---| "ln" Lingala
---| "lt" Lithuanian
---| "lg" Luganda
---| "lb" Luxembourgish
---| "mk" Macedonian
---| "mai" Maithili
---| "mg" Malagasy
---| "ms" Malay
---| "ml" Malayalam
---| "mt" Maltese
---| "mi" Maori
---| "mr" Marathi
---| "mni-Mtei" Meiteilon (Manipuri)
---| "lus" Mizo
---| "mn" Mongolian
---| "my" Myanmar (Burmese)
---| "ne" Nepali
---| "no" Norwegian
---| "ny" Nyanja (Chichewa)
---| "or" Odia (Oriya)
---| "om" Oromo
---| "ps" Pashto
---| "fa" Persian
---| "pl" Polish
---| "pt" Portuguese (Portugal, Brazil)
---| "pa" Punjabi
---| "qu" Quechua
---| "ro" Romanian
---| "ru" Russian
---| "sm" Samoan
---| "sa" Sanskrit
---| "gd" Scots Gaelic
---| "nso" Sepedi
---| "sr" Serbian
---| "st" Sesotho
---| "sn" Shona
---| "sd" Sindhi
---| "si" Sinhala (Sinhalese)
---| "sk" Slovak
---| "sl" Slovenian
---| "so" Somali
---| "es" Spanish
---| "su" Sundanese
---| "sw" Swahili
---| "sv" Swedish
---| "tl" Tagalog (Filipino)
---| "tg" Tajik
---| "ta" Tamil
---| "tt" Tatar
---| "te" Telugu
---| "th" Thai
---| "ti" Tigrinya
---| "ts" Tsonga
---| "tr" Turkish
---| "tk" Turkmen
---| "ak" Twi (Akan)
---| "uk" Ukrainian
---| "ur" Urdu
---| "ug" Uyghur
---| "uz" Uzbek
---| "vi" Vietnamese
---| "cy" Welsh
---| "xh" Xhosa
---| "yi" Yiddish
---| "yo" Yoruba
---| "zu" Zulu
-- }}}
--}}}

-- Define Text loader {{{
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

-- Define Text formatter {{{
-- Format the translated string

---@param text string @translated text
---@return string[] @formatted text list
local format_text_ja = function(text)
    -- split text from 。
    local line_breaker = "。"
    local formatted_text = vim.fn.split(text, line_breaker .. '\\s*\\zs')
    -- local formatted_text = vim.fn.split(text, line_breaker)
    return formatted_text
end

---@param text string @translated text
---@return string[] @formatted text
local format_text_en = function(text)
    local line_breaker = "\\."
    local formatted_text = vim.fn.split(text, line_breaker .. '\\s*\\zs')
    return formatted_text
end

local text_formatters = {
    ['ja'] = format_text_ja,
    ['en'] = format_text_en,
}
---@param language LANG
---@param text string
---@return string[] @formatted text
M.format_text = function(language, text)
    -- common format process
    -- remove continurous white spaces
    text = string.gsub(text, '%s+', ' ')

    -- if unique formatter is found, return formatted text.
    local text_formatter = text_formatters[language]
    if not text_formatter then
        return {text}
    end

    -- if no unique formatter is found, return as is.
    local formatted_data = text_formatter(text)
    return formatted_data
end
-- }}}

-- Define URL encoder {{{
local char_to_hex = function(c)
    return string.format("%%%02X", string.byte(c))
end

local function url_encode(url)
    if url == nil then
        return
    end
    url = url:gsub("\n", "\r\n")
    url = url:gsub("([^%w ])", char_to_hex)
    url = url:gsub(" ", "+")
    return url
end
-- }}}

-- Create reqest paramater to hit the translate API{{{
---@type fun(text: string, src: LANG, dst: LANG): string?
M.create_req_params = function(text, src, dst)
    -- source text must be less than 3000 characters
    if string.len(text) > TEXT_LEN_LIMIT then
        vim.notify("the text must be less than 3,000 characters", vim.log.levels.WARN)
        return nil
    end

    -- remove line breaks
    text = text:gsub("\r?\n", " ")

    -- Perform URL encoding
    local req_text = url_encode(text)

    -- create reqest paramater
    local req_params = ""
    req_params = req_params .. "?" .. REQUEST_PARAM_KEY.txt .. "=" .. req_text
    req_params = req_params .. "&" .. REQUEST_PARAM_KEY.src .. "=" .. src
    req_params = req_params .. "&" .. REQUEST_PARAM_KEY.dst .. "=" .. dst
    return req_params
end
-- }}}

-- Execute translation{{{
---@param text string
---@param src LANG
---@param dst LANG
---@param on_success function
---@param on_err function
M.translate = function(text, src, dst, on_success, on_err)
    local url = URL_TRANSLATOR .. M.create_req_params(text, src, dst)
    local cmd_list = {
        ['curl'] = { "-sSL", url },
        ['wget'] = { "-qO-", url }
    }
    for cmd, cmd_args in pairs(cmd_list) do
        if vim.fn.executable(cmd) == 1 then
            async.execute_cmd_async(cmd, cmd_args, on_success, on_err)
            return
        end
    end
    vim.notify('curl or wget is required to perform the translation.', vim.log.levels.ERROR)
end
-- }}}

return M
