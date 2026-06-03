require("quarto").setup({
    lspFeatures = {
        languages = { "python" },
        completion = { enabled = true },
        diagnostics = { enabled = true },
    },
    codeRunner = {
        enabled = true,
        default_method = "molten",
    },
})

local runner = require("quarto.runner")
local k = vim.keymap.set
local opts = function(desc) return { desc = desc, noremap = true, silent = true } end

k("n", "<leader>jc", runner.run_cell,  opts("[J]upyter run [C]ell"))
k("n", "<leader>ja", runner.run_above, opts("[J]upyter run [A]ll above"))
k("n", "<leader>jA", runner.run_all,   opts("[J]upyter run [A]ll"))
