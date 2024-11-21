require('telescope').setup {
    defaults = {
        mappings = {
            i = {
                ['<C-u>'] = false, -- Set C-u to clear the prompt instead of scroll up
                ['<C-d>'] = false, -- Set C-d to delete the buffer?
            },
        },
        -- configure to use ripgrep
        vimgrep_arguments = {
            "rg",
            "--follow",        -- Follow symbolic links
            "--hidden",        -- Search for hidden files
            "--no-heading",    -- Don't group matches by each file
            "--with-filename", -- Print the file path with the matched lines
            "--line-number",   -- Show line numbers
            "--column",        -- Show column numbers
            "--smart-case",    -- Smart case search

            -- Exclude some patterns from search
            "--glob=!**/.git/*",
            "--glob=!**/.idea/*",
            "--glob=!**/.vscode/*",
            "--glob=!**/build/*",
            "--glob=!**/dist/*",
            "--glob=!**/yarn.lock",
            "--glob=!**/package-lock.json",
        },
    },
    pickers = {
        find_files = {
            hidden = true,
            -- needed to exclude some files & dirs from general search
            -- when not included or specified in .gitignore
            find_command = {
                "rg",
                "--files",
                "--hidden",
                "--glob=!**/.git/*",
                "--glob=!**/.idea/*",
                "--glob=!**/.vscode/*",
                "--glob=!**/build/*",
                "--glob=!**/dist/*",
                "--glob=!**/yarn.lock",
                "--glob=!**/package-lock.json",
            },
        },
    },
}
-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')


local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = '[B]uffers' })
vim.keymap.set('n', '<leader>fp', builtin.find_files, { desc = '[F]ind [P]roject files' })
vim.keymap.set('n', '<leader>fg', builtin.git_files, { desc = '[F]ind [G]it files' })
vim.keymap.set('n', '<leader>fws', builtin.lsp_dynamic_workspace_symbols, { desc = '[F]ind [W]orkspace [S]ymbol' })
vim.keymap.set('n', '<leader>db', builtin.diagnostics, { desc = '[D]iagnostics in [B]uffer' })
vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
    })
end, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>fs', builtin.live_grep, { desc = '[F]ind by [S]earch' })
