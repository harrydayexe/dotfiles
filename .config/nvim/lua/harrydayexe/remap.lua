vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = 'Go to file view' })

-- Move visual block up or down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '>-2<CR>gv=gv")

-- Overide normal J behaviour by keeping cursor at start of line
vim.keymap.set('n', 'J', 'mzJ`z')

-- Override normal n and N behaviour by keeping cursor centered
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Override normal C-d and C-u behaviour by keeping cursor centered
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Jump to EOF centers cursor
vim.keymap.set('n', 'G', 'Gzz')

-- Paste over selected text without losing selection
vim.keymap.set('x', '<Leader>p', '"_dP')

-- yank into system clipboard : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = '[Y]ank to Clipboard' })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = '[Y]ank line to Clipboard' })

-- delete to void register
vim.keymap.set({ "n", "v" }, "<leader>x", [["_d]], { desc = 'Delete to Void Register' })

vim.keymap.set("n", "Q", "<nop>")

-- replace current word
vim.keymap.set("n", "<leader>ec", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = 'Replace [C]urrent Word' })

-- Unbind arrow keys
vim.keymap.set("n", "<Up>", "<nop>")
vim.keymap.set("n", "<Down>", "<nop>")
vim.keymap.set("n", "<Left>", "<nop>")
vim.keymap.set("n", "<Right>", "<nop>")

-- Go to dotfiles
vim.keymap.set("n", "<leader><leader>d",
    "<cmd>cd /Users/harryday/Developer/dotfiles<cr><cmd>Oil<cr>",
    { desc = "Open [D]otfiles Workspace" })

-- Go to dotfiles/nvim
vim.keymap.set("n", "<leader><leader>v",
    "<cmd>cd /Users/harryday/Developer/dotfiles/.config/nvim/<cr><cmd>Oil<cr>",
    { desc = "Open Neo[V]im Config Workspace" })

-- Open image under cursor in the Preview app (macOS)
vim.keymap.set("n", "<leader>ov", function()
    local function get_image_path()
        -- Get the current line
        local line = vim.api.nvim_get_current_line()
        -- Pattern to match image path in Markdown
        local image_pattern = "%[.-%]%((.-)%)"
        -- Extract relative image path
        local _, _, image_path = string.find(line, image_pattern)

        return image_path
    end

    -- Get the image path
    local image_path = get_image_path()

    if image_path then
        -- Check if the image path starts with "http" or "https"
        if string.sub(image_path, 1, 4) == "http" then
            print("URL image, use 'gx' to open it in the default browser.")
        else
            -- Construct absolute image path
            local current_file_path = vim.fn.expand("%:p:h")
            local absolute_image_path = current_file_path .. "/" .. image_path

            -- Construct command to open image in Preview
            local command = "open -a Preview " .. vim.fn.shellescape(absolute_image_path)
            -- Execute the command
            local success = os.execute(command)

            if success then
                print("Opened image in Preview: " .. absolute_image_path)
            else
                print("Failed to open image in Preview: " .. absolute_image_path)
            end
        end
    else
        print("No image found under the cursor")
    end
end, { desc = "[O]bsidian Pre[V]iew Image Under Cursor" })


-- Open image under cursor in Finder (macOS)
--
-- THIS ONLY WORKS IF YOU'RE NNNNNOOOOOOTTTTT USING ABSOLUTE PATHS,
-- BUT INSTEAD YOURE USING RELATIVE PATHS
--
-- If using absolute paths, use the default `gx` to open the image instead
vim.keymap.set("n", "<leader>of", function()
    local function get_image_path()
        -- Get the current line
        local line = vim.api.nvim_get_current_line()
        -- Pattern to match image path in Markdown
        local image_pattern = "%[.-%]%((.-)%)"
        -- Extract relative image path
        local _, _, image_path = string.find(line, image_pattern)

        return image_path
    end

    -- Get the image path
    local image_path = get_image_path()

    if image_path then
        -- Check if the image path starts with "http" or "https"
        if string.sub(image_path, 1, 4) == "http" then
            print("URL image, use 'gx' to open it in the default browser.")
        else
            -- Construct absolute image path
            local current_file_path = vim.fn.expand("%:p:h")
            local absolute_image_path = current_file_path .. "/" .. image_path

            -- Open the containing folder in Finder and select the image file
            local command = "open -R " .. vim.fn.shellescape(absolute_image_path)
            local success = vim.fn.system(command)

            if success == 0 then
                print("Opened image in Finder: " .. absolute_image_path)
            else
                print("Failed to open image in Finder: " .. absolute_image_path)
            end
        end
    else
        print("No image found under the cursor")
    end
end, { desc = "[O]bsidian Show Image Under Cursor in [F]inder" })
