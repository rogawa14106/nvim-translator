local M = {}
local translator = require('nvim-translator.translator')
local ui = require('nvim-translator.ui')

M.main = function()
    -- open floating window
    ui.new()

    -- draw spinner to notify user now wating
    ui.overwrite_lines({"test"})

    -- translate text asynchronously(stop spinner in callback function on_success)
end

-- M.main()

return M
