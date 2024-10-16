-- duplication check
if vim.g.loaded_nvim_translator then
    return
end
vim.g.loaded_nvim_translator = true

-- nvim check
if vim.fn.has('nvim') ~= 1 then
    vim.notify("this plugin only support nvim.", vim.log.levels.ERROR)
    return
end

-- nvim version check (support >= nvim 0.10.0)
---@type (vim.Version)?
local nvim_local_v = vim.version.parse(vim.fn.system({ 'nvim', '-v' }), { strict = false })
---@type number[]
local nvim_support_v = { 0, 10, 0 }
if (nvim_local_v ~= nil) and (vim.version.lt(nvim_local_v, nvim_support_v)) then
    vim.notify(
        "this plugin only support nvim version => "
        .. nvim_support_v[1] .. nvim_support_v[2] .. nvim_support_v[3],
        vim.log.levels.ERROR
    )
end

require('nvim-translator').init()

-- init
-- require('nvim-translator').setup()

-- Ex commands
-- TODO create user command
-- vim.api.nvim_create_user_command(
    -- "Translate",
    -- function()
    -- end,
    -- { bang = true }
-- )

-- default keymap TODO
-- TODO create keymap
-- vim.api.nvim_set_keymap("n", "<Leader>?", "", {
    -- callback = function ()
    -- end,
-- })

