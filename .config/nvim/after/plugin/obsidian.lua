require("obsidian").setup({
    workspaces = {
        {
            name = "harrydayexe",
            path = "/Users/harryday/Library/Mobile Documents/iCloud~md~obsidian/Documents/harrydayexe",
        },
    },
    notes_subdir = "inbox",
    new_notes_location = "notes_subdir",

    daily_notes = {
        folder = "daily",
        default_tags = { "daily" },
        template =
        "/Users/harryday/Library/Mobile Documents/iCloud~md~obsidian/Documents/harrydayexe/templates/Daily-template.md",
    },

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
    "<cmd>cd /Users/harryday/library/Mobile\\ Documents/iCloud~md~obsidian/Documents/harrydayexe<cr><cmd>Oil<cr>",
    { desc = "[O]pen [O]bsidian Workspace" })

-- for review workflow
-- move file in current buffer to zettelkasten folder
vim.keymap.set("n", "<leader>ok",
    "<cmd>!mv '%:p' /Users/harryday/library/Mobile\\ Documents/iCloud~md~obsidian/Documents/harrydayexe/zettelkasten<cr><cmd>Bdelete<cr>",
    { desc = "[O]bsidian O[K]ay" })
-- delete file in current buffer
vim.keymap.set("n", "<leader>od", "<Nop>", { desc = "[O]bsidian [D]elete [D]ocument", silent = true })
vim.keymap.set("n", "<leader>odd", "<cmd>!rm '%:p'<cr><cmd>Bdelete<cr>",
    { desc = "[O]bsidian [D]elete [D]ocument" })

-- search for files in full vault
vim.keymap.set("n", "<leader>fop",
    ":Telescope find_files search_dirs={\"/Users/harryday/library/Mobile\\ Documents/iCloud~md~obsidian/Documents/harrydayexe/notes\"}<cr>",
    { desc = "[F]ind [O]bsidian [P]roject files" })
vim.keymap.set("n", "<leader>fos",
    ":Telescope live_grep search_dirs={\"/Users/harryday/library/Mobile\\ Documents/iCloud~md~obsidian/Documents/harrydayexe/notes\"}<cr>",
    { desc = "[F]ind [O]bsidian by [S]earch" })

-- Daily notes
vim.keymap.set("n", "<leader>oy", "<cmd>ObsidianToday -1<cr>", { desc = "[O]bsidian [Y]esterday" })
vim.keymap.set("n", "<leader>ot", "<cmd>ObsidianToday<cr>", { desc = "[O]bsidian [T]oday" })

-- create a new note
-- Define a function to create a vertical split, prompt for input, and run the command
local function new_obsidian_note()
    -- Prompt for input
    local input = vim.fn.input("Enter file name: ")
    if input == nil or input == "" then
        print("No input provided.")
        return
    end

    -- Wrap the input in quotes using shellescape
    local escaped_input = vim.fn.shellescape(input)
    local cmd = "on-nvim " .. escaped_input

    -- Execute the script and capture its output (the file path)
    local file_path = vim.fn.system(cmd)
    file_path = vim.fn.trim(file_path)

    if file_path == "" then
        print("Script did not return a file path.")
        return
    end

    -- Open the file in a vertical split.
    vim.cmd("vsplit " .. vim.fn.fnameescape(file_path))
end

vim.api.nvim_create_user_command("ObsidianNewNote", new_obsidian_note, {})

-- Map the function to a keybinding (for example, <Leader>o in normal mode)
vim.api.nvim_set_keymap('n', '<Leader>on', ':ObsidianNewNote<CR>',
    { desc = "[O]bsidian [N]ote", noremap = true, silent = true })
