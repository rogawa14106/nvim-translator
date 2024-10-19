local M = {}

local main = require('nvim-translator.main')
vim.api.nvim_set_keymap("n", "<Leader>?", "", {
    callback = function()
        main()
    end,
})

return M
