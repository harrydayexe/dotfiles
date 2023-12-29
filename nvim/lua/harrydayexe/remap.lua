vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = '[P]roject [V]iew' })

-- Move visual block up or down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '>-2<CR>gv=gv")

-- Overide normal J behaviour by keeping cursor at start of line
vim.keymap.set('n', 'J', 'mzJ`z')

-- Override normal n and N behaviour by keeping cursor centered
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Paste over selected text without losing selection
vim.keymap.set('x', '<Leader>p', '"_dP')

-- yank into system clipboard : asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], { desc = '[Y]ank to Clipboard' })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = '[Y]ank line to Clipboard' })

-- delete to void register
vim.keymap.set({"n", "v"}, "<leader>x", [["_d]], { desc = 'Delete to Void Register' })

vim.keymap.set("n", "Q", "<nop>")

-- replace current word
vim.keymap.set("n", "<leader>ec", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = 'Replace [C]urrent Word' })
