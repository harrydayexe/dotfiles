require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false, -- Set C-u to clear the prompt instead of scroll up
        ['<C-d>'] = false, -- Set C-d to delete the buffer?
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')


local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>fp', builtin.find_files, { desc = '[F]ind [P]roject files' })
vim.keymap.set('n', '<leader>fg', builtin.git_files, { desc = '[F]ind [G]it files' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>fs', builtin.live_grep, { desc = '[F]ind by [S]earch' })

require('which-key').register {
    ['<leader>f'] = { name = '[F]ind', _ = 'which_key_ignore' },
}
