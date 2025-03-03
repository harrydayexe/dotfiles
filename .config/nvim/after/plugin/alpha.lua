local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- Set header
dashboard.section.header.val = {
    " _                               _                           ",
    "| |__   __ _ _ __ _ __ _   _  __| | __ _ _   _  _____  _____ ",
    "| '_ \\ / _` | '__| '__| | | |/ _` |/ _` | | | |/ _ \\ \\/ / _ \\",
    "| | | | (_| | |  | |  | |_| | (_| | (_| | |_| |  __/>  <  __/",
    "|_| |_|\\__,_|_|  |_|   \\__, |\\__,_|\\__,_|\\__, |\\___/_/\\_\\___|",
    "                       |___/             |___/               ",
}

-- Set menu
dashboard.section.buttons.val = {
    dashboard.button("on", "  > New Obsidian Note", "<cmd>ObsidianNewNote<CR>"),
    dashboard.button("oo", " > Open Obsidian Vault",
        "<cmd>cd /Users/harryday/library/Mobile\\ Documents/iCloud~md~obsidian/Documents/harrydayexe<cr><cmd>Oil<cr>"),
    dashboard.button("-", " > Open Current Directory", "<cmd>Oil<CR>"),
    dashboard.button("ff", "󰥨 > Find Folder", "<cmd>Telescope oil<CR>"),
    dashboard.button("fp", "󱙓 > Find File", "<cmd>Telescope find_files<CR>"),
    dashboard.button("fs", " > Fuzzy Find in File", "<cmd>Telescope live_grep<CR>"),
    dashboard.button("fr", "  > Recent", "<cmd>Telescope oldfiles<CR>"),
    dashboard.button("d", " > Open Dotfiles Workspace", "<cmd>cd /Users/harryday/Developer/dotfiles<cr><cmd>Oil<cr>"),
    dashboard.button("v", " > Open NeoVim Config",
        "<cmd>cd /Users/harryday/Developer/dotfiles/.config/nvim/<cr><cmd>Oil<cr>"),
    dashboard.button("q", "󰩈 > Quit NVIM", "<cmd>qa<CR>"),
}

-- Set footer
local fortune = require("alpha.fortune")
dashboard.section.footer.val = fortune()

-- Send config to alpha
alpha.setup(dashboard.opts)

-- Disable folding on alpha buffer
vim.cmd([[
    autocmd FileType alpha setlocal nofoldenable
]])

-- Create an augroup for the autocommand
vim.api.nvim_create_augroup("AlphaOnEmpty", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
    group = "AlphaOnEmpty",
    callback = function()
        -- Get a list of all listed buffers
        local bufs = vim.fn.getbufinfo({ buflisted = 1 })
        -- If there's only one listed buffer and it has no name,
        -- assume it's the empty buffer left after deleting everything.
        if #bufs == 2 and bufs[2].name == "" then
            -- require("alpha").start(true)
            vim.cmd("Alpha")
        end
    end,
})

function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end
