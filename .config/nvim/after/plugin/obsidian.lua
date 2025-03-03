require("obsidian").setup({
    workspaces = {
        {
            name = "harrydayexe",
            path = "/Users/harryday/Library/Mobile Documents/iCloud~md~obsidian/Documents/harrydayexe",
        },
    },
    notes_subdir = "inbox",
    new_notes_location = "notes_subdir",


    disable_frontmatter = true,
    templates = {
        subdir = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M:%S",
    },

    -- name new notes starting the ISO datetime and ending with note name
    -- put them in the inbox subdir
    -- note_id_func = function(title)
    --     local suffix = ""
    --     -- get current ISO datetime with -5 hour offset from UTC for EST
    --     local current_datetime = os.date("!%Y-%m-%d-%H%M%S", os.time() - 5 * 3600)
    --     if title ~= nil then
    --         suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
    --     else
    --         for _ = 1, 4 do
    --             suffix = suffix .. string.char(math.random(65, 90))
    --         end
    --     end
    --     return current_datetime .. "_" .. suffix
    -- end,

    -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
    -- URL it will be ignored but you can customize this behavior here.
    ---@param url string
    follow_url_func = function(url)
        -- Open the URL in the default web browser.
        vim.fn.jobstart({ "open", url }) -- Mac OS
    end,

    -- Optional, by default when you use `:ObsidianFollowLink` on a link to an image
    -- file it will be ignored but you can customize this behavior here.
    ---@param img string
    follow_img_func = function(img)
        vim.fn.jobstart { "qlmanage", "-p", img } -- Mac OS quick look preview
    end,

    -- key mappings, below are the defaults
    mappings = {
        -- overrides the 'gf' mapping to work on markdown/wiki links within your vault
        ["gf"] = {
            action = function()
                return require("obsidian").util.gf_passthrough()
            end,
            opts = { noremap = false, expr = true, buffer = true, desc = '[G]o [F]ollow' },
        },
        -- toggle check-boxes
        ["<leader>oc"] = {
            action = function()
                return require("obsidian").util.toggle_checkbox()
            end,
            opts = { buffer = true, desc = 'Toggle [O]bsidian [C]heckbox' },
        },
    },
    completion = {
        nvim_cmp = true,
        min_chars = 2,
    },
    -- ui = {
    --     enable = false,
    -- }
    -- ui = {
    --     -- Disable some things below here because I set these manually for all Markdown files using treesitter
    --     checkboxes = {},
    --     bullets = {},
    -- },
})

vim.keymap.set("n", "<leader>oo",
    ":cd /Users/harryday/library/Mobile\\ Documents/iCloud~md~obsidian/Documents/harrydayexe<cr>",
    { desc = "[O]pen [O]bsidian Workspace" })

-- for review workflow
-- move file in current buffer to zettelkasten folder
vim.keymap.set("n", "<leader>ok",
    "<cmd>!mv '%:p' /Users/harryday/library/Mobile\\ Documents/iCloud~md~obsidian/Documents/harrydayexe/zettelkasten<cr><cmd>bd<cr>",
    { desc = "[O]bsidian O[K]ay" })
-- delete file in current buffer
vim.keymap.set("n", "<leader>odd", "<cmd>!rm '%:p'<cr><cmd>bd<cr>", { desc = "[O]bsidian [D]elete [D]ocument" })
