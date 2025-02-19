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

-- Wrap selected text in quotes
vim.keymap.set("v", "<leader>'", [[:s/\%V.*/"&"/<CR>]])
