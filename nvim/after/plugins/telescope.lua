-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')



local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
