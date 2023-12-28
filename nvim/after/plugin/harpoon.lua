local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup({})
-- REQUIRED


-- basic telescope configuration
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
    end

    require("telescope.pickers").new({}, {
        prompt_title = "Harpoon",
        finder = require("telescope.finders").new_table({
            results = file_paths,
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
    }):find()
end

vim.keymap.set("n", "<leader>hh", function() toggle_telescope(harpoon:list()) end,
    { desc = "Open [H]arpoon window" })

vim.keymap.set("n", "<leader>ha", function() harpoon:list():append() end, { desc = "[A]ppend current file to harpoon" })

vim.keymap.set("n", "<leader>h1", function() harpoon:list():select(1) end, { desc = "Select [1]st harpoon entry" })
vim.keymap.set("n", "<leader>h2", function() harpoon:list():select(2) end, { desc = "Select [2]nd harpoon entry" })
vim.keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end, { desc = "Select [3]rd harpoon entry" })
vim.keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end, { desc = "Select [4]th harpoon entry" })
vim.keymap.set("n", "<leader>h5", function() harpoon:list():select(4) end, { desc = "Select [5]th harpoon entry" })
vim.keymap.set("n", "<leader>h6", function() harpoon:list():select(4) end, { desc = "Select [6]th harpoon entry" })
vim.keymap.set("n", "<leader>h7", function() harpoon:list():select(4) end, { desc = "Select [7]th harpoon entry" })
vim.keymap.set("n", "<leader>h8", function() harpoon:list():select(4) end, { desc = "Select [8]th harpoon entry" })
vim.keymap.set("n", "<leader>h9", function() harpoon:list():select(4) end, { desc = "Select [9]th harpoon entry" })

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<leader>hp", function() harpoon:list():prev() end, { desc = "Select [P]revious harpoon entry" })
vim.keymap.set("n", "<leader>hp", function() harpoon:list():next() end, { desc = "Select [N]ext harpoon entry" })
