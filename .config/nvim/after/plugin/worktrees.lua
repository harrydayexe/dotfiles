local Job = require('plenary.job')
local Path = require('plenary.path')

local Status = require('git-worktree.status')

local status = Status:new()
local M = {}
local git_worktree_root = vim.loop.cwd()
local on_change_callbacks = {}

local function on_tree_change_handler(op, path, _) -- _ = upstream
    if M._config.update_on_change then
        if op == "switch" then
            local changed = M.update_current_buffer()
            if not changed then
                vim.cwd(string.format(":Ex %s", M.get_worktree_path(path)))
            end
        end
    end
end
