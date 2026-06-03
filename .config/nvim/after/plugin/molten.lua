vim.g.molten_image_provider = "image.nvim"
vim.g.molten_auto_open_output = false
vim.g.molten_virt_text_output = true
vim.g.molten_wrap_output = true
vim.g.molten_output_win_max_height = 20
vim.g.molten_virt_lines_off_by_1 = true

-- when a kernel is initialized, auto-import any saved outputs from the .ipynb file
vim.api.nvim_create_autocmd("User", {
    pattern = "MoltenInitPost",
    callback = function()
        pcall(vim.cmd, "MoltenImportOutput")
    end,
})

-- on save, write cell outputs back into the .ipynb file
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.ipynb",
    callback = function()
        pcall(vim.cmd, "MoltenExportOutput!")
    end,
})

local k = vim.keymap.set
local opts = function(desc) return { desc = desc, noremap = true, silent = true } end

k("n", "<leader>ji", ":MoltenInit<CR>",                    opts("[J]upyter [I]nit kernel"))
k("n", "<leader>je", ":MoltenEvaluateOperator<CR>",        opts("[J]upyter [E]valuate (operator)"))
k("n", "<leader>jl", ":MoltenEvaluateLine<CR>",            opts("[J]upyter evaluate [L]ine"))
k("v", "<leader>jv", ":<C-u>MoltenEvaluateVisual<CR>",     opts("[J]upyter evaluate [V]isual"))
k("n", "<leader>jr", ":MoltenReevaluateCell<CR>",          opts("[J]upyter [R]e-evaluate cell"))
k("n", "<leader>jo", ":MoltenEnterOutput<CR>",             opts("[J]upyter [O]pen output"))
k("n", "<leader>jh", ":MoltenHideOutput<CR>",              opts("[J]upyter [H]ide output"))
k("n", "<leader>jd", ":MoltenDelete<CR>",                  opts("[J]upyter [D]elete cell output"))
k("n", "<leader>jR", ":MoltenRestart<CR>",                 opts("[J]upyter [R]estart kernel"))
k("n", "<leader>jx", ":MoltenInterrupt<CR>",               opts("[J]upyter interrupt e[X]ecution"))
