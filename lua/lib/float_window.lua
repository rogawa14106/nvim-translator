---floating window configuration type
---@class FWinConfig
---@field name string
---@field window FWinWindowConfig
---@field options FwinOptionConfig
---@field keymaps FwinKeymapConfig[]
---@field autocmd FwinAutocmdConfig[]
---@field initial_lines string[]? initial text lines

---floating window configuration
---@alias FWinWindowConfig vim.api.keyset.win_config

---options configuration
---@class FwinOptionConfig
---@field win FwinOptionTable[]
---@field buf FwinOptionTable[]
---@field hl FwinHlOptionTable[]

---window/buffer options set on floating window
---@class FwinOptionTable
---@field name string name of option
---@field value string|integer|table|boolean value of option

---syntax highlighting configuration set on floating window
---@class FwinHlOptionTable
---@field name string name of option
---@field value vim.api.keyset.highlight value of highlihght option
---
---keymap configuration set on floating window
---@class FwinKeymapConfig
---@field is_buf boolean
---@field mode string Mode short-name ("n", "i", "v", ...)
---@field lhs string — Left-hand-side `{lhs}` of the mapping.
---@field rhs string — Right-hand-side `{rhs}` of the mapping.
---@field opts table vim.api.keyset.keymap Optional parameters map: Accepts all `:map-arguments` as keys except [<buffer>], values are booleans (default false).

---autocmd config
---@class FwinAutocmdConfig
---@field is_buf boolean
---@field event string|string[] Event(s) that will trigger the handler
---@field opts table vim.api.keyset.create_autocmd

---floating window type
---@class FloatWindow
---@field config FWinConfig
---@field bufnr integer
---@field winid integer
---@field init fun(config: FWinConfig): nil
---@field create_buf fun(): integer
---@field open_win fun(): integer?
---@field change_opt fun():nil implement not yet
---@field write_lines fun(startl: integer, endl: integer, lines: string[])
---@field close_win fun():nil
---@field send_cmd fun():nil

---@type fun(): FloatWindow
local new = function()
    -- FloatWindow member variables
    local self = {
        config = {},
        bufnr = nil,
        winid = nil, -- 'winid' can be derived from 'bufnr', but retain 'winid' in variable because processing steps is reduced.
        --         pre_winid = nil, TODO add implement to back most recent winid when change window
        --         buflines = {},
        --         bufinfos = {},
        -- member methods

        init = function() end,
        create_buf = function() end,
        open_win = function() end,
        change_opt = function() end,
        write_lines = function() end,
        close_win = function() end,
        send_cmd = function() end,
    }

    -- private members
    local _self = {
        -- member variables
        debug_flg = false,
        --         debug_flg = true,
        bufnr_key = nil,
        -- member methods
        set_keymap = function() end,
        set_autocmd = function() end,
        set_bufopt = function() end,
        set_winopt = function() end,
        set_highlight = function() end,
    }

    ---@type fun(config: FWinConfig):nil
    self.init = function(config)
        -- self.config_init = config
        self.config = config

        _self.bufnr_key = self.config.name .. "_bufnr"

        self.create_buf()
        self.open_win()
        if self.config.initial_lines then
            self.write_lines(0, -1, self.config.initial_lines)
        end
        _self.set_bufopt()
        _self.set_winopt()
        _self.set_keymap()
        _self.set_highlight()
        _self.set_autocmd()
    end

    self.create_buf = function()
        local bufnr = vim.g[_self.bufnr_key]
        -- if global val <winname>_bufnr is nil
        if (bufnr == nil) or (vim.fn.bufexists(bufnr) == 0) then
            bufnr = vim.api.nvim_create_buf(false, true)
            vim.g[_self.bufnr_key] = bufnr
        end
        self.bufnr = bufnr
        return bufnr
    end

    self.open_win = function()
        local opt_win = self.config.window
        if self.bufnr == nil then
            vim.notify("buffer that used to open floating window is not initialized", vim.log.levels.ERROR)
            return
        end

        local winid_table = vim.fn.win_findbuf(self.bufnr)
        local winid = winid_table[1]
        if winid == nil then
            winid = vim.api.nvim_open_win(self.bufnr, opt_win.focusable, opt_win)
        else
            if opt_win.focusable == true then
                vim.fn.win_gotoid(winid)
            end
        end
        self.winid = winid
        return winid
    end

    self.write_lines = function(startl, endl, lines)
        for i = 1, #lines do
            --末尾に改行があったら、削除する
            lines[i] = lines[i]:gsub("\r?\n$", "")
        end
        vim.api.nvim_set_option_value('modifiable', true, { buf = self.bufnr })
        vim.api.nvim_set_option_value('readonly', false, { buf = self.bufnr })
        vim.api.nvim_buf_set_lines(self.bufnr, startl, endl, false, lines)
        vim.api.nvim_set_option_value('modifiable', false, { buf = self.bufnr })
        vim.api.nvim_set_option_value('readonly', true, { buf = self.bufnr })
        vim.cmd("redraw")
    end

    self.close_win = function()
        if (self.winid ~= nil) and (#vim.fn.win_findbuf(self.bufnr) > 0) then
            vim.api.nvim_win_close(self.winid, true)
        end
        local augroup_id = vim.api.nvim_create_augroup(self.config.name, { clear = true })
        if augroup_id ~= nil then
            vim.api.nvim_del_augroup_by_id(augroup_id)
        end
    end

    self.change_opt = function()
    end

    self.send_cmd = function(cmd)
        vim.cmd(cmd)
    end

    _self.set_keymap = function()
        local keymap_table = self.config.keymaps
        if keymap_table == nil then
            return
        end

        if #keymap_table == 0 then
            return
        end

        for i = 1, #keymap_table do
            local keymap = keymap_table[i]
            -- local require_opts = { "is_buf", "mode", "lhs", "rhs" }
            -- if _self.validate_table(keymap, require_opts) == false then
            -- vim.notify("invalid keymap options. require following keys" .. vim.inspect(require_opts),
            -- vim.log.levels.ERROR)
            -- goto continue
            -- end

            if keymap.is_buf == true then
                vim.api.nvim_buf_set_keymap(self.bufnr, keymap.mode, keymap.lhs, keymap.rhs, keymap.opts)
            else
                vim.api.nvim_set_keymap(keymap.mode, keymap.lhs, keymap.rhs, keymap.opts)
            end
            -- ::continue::
        end
    end

    _self.set_autocmd = function()
        local autocmd_table = self.config.autocmd
        if autocmd_table == nil then
            return
        end

        if #autocmd_table == 0 then
            return
        end

        -- clear & create autocmd group
        vim.api.nvim_create_augroup(self.config.name, { clear = true })

        -- create autocmd
        for i = 1, #autocmd_table do
            local autocmd = autocmd_table[i]
            -- local require_opts = { "is_buf", "event", "opts" }
            -- if _self.validate_table(autocmd, require_opts) == false then
            -- vim.notify("invalid autocmd options. require following keys" .. vim.inspect(require_opts),
            -- vim.log.levels.ERROR)
            -- goto continue
            -- end

            -- add group to autocmd option
            autocmd.opts.group = self.config.name
            if autocmd.is_buf == true then
                -- add buffer to autocmd option
                autocmd.opts.buffer = self.bufnr
                vim.api.nvim_create_autocmd(autocmd.event, autocmd.opts)
            else
                vim.api.nvim_create_autocmd(autocmd.event, autocmd.opts)
            end
            -- ::continue::
        end
    end

    _self.set_bufopt = function()
        local bufopt_table = self.config.options.buf
        if bufopt_table == nil then
            return
        end

        if #bufopt_table == 0 then
            return
        end

        for i = 1, #bufopt_table do
            local bufopt = bufopt_table[i]
            -- local require_opts = { "name", "value" }
            -- if _self.validate_table(bufopt, require_opts) == false then
            -- vim.notify("invalid buffer options. require following keys" .. vim.inspect(require_opts),
            -- vim.log.levels.ERROR)
            -- goto continue
            -- end
            vim.api.nvim_set_option_value(bufopt.name, bufopt.value, { buf = self.bufnr })
            -- ::continue::
        end
    end

    _self.set_winopt = function()
        local winopt_table = self.config.options.win
        if winopt_table == nil then
            return
        end

        if #winopt_table == 0 then
            return
        end

        for i = 1, #winopt_table do
            local winopt = winopt_table[i]
            -- local require_opts = { "name", "value" }
            -- if _self.validate_table(winopt, require_opts) == false then
            -- vim.notify("invalid window options. require following keys" .. vim.inspect(require_opts),
            -- vim.log.levels.ERROR)
            -- goto continue
            -- end
            vim.api.nvim_set_option_value(winopt.name, winopt.value, { win = self.winid })
            -- ::continue::
        end
    end

    _self.set_highlight = function()
        local hlopt_table = self.config.options.hl
        if (hlopt_table == nil) or (#hlopt_table == 0) then
            return
        end

        local ns_id = vim.api.nvim_create_namespace(self.config.name)
        --         vim.api.nvim_add_highlight()
        --         vim.api.nvim_set_hl_ns()
        for i = 1, #hlopt_table do
            local hlopt = hlopt_table[i]
            -- local require_opts = { "name", "value" }
            -- if _self.validate_table(hlopt, require_opts) == false then
            -- vim.notify("invalid highlight options. require following keys" .. vim.inspect(require_opts),
            -- vim.log.levels.ERROR)
            -- goto continue
            -- end
            vim.api.nvim_set_hl(ns_id, hlopt.name, hlopt.value)
            ::continue::
        end

        vim.api.nvim_win_set_hl_ns(self.winid, ns_id)
    end

    _self.validate_table = function(table, requires)
        local is_valid = true
        for i = 1, #requires do
            if table[requires[i]] == nil then
                is_valid = false
            end
        end
        return is_valid
    end
    return self
end

return {
    new = new,
}
