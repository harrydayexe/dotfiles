vim.keymap.set("n", "<leader>dt", "<cmd>TodoTelescope<CR>",
    { noremap = true, silent = true, desc = "Show TODOs in [T]elescope" })

vim.keymap.set("n", "<leader>dq", "<cmd>TodoQuickFix<CR>",
    { noremap = true, silent = true, desc = "Show TODOs in [Q]uick Fix" })
