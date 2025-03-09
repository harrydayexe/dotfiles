require("autoclose").setup({
    keys = {
        ["`"] = { escape = true, close = true, pair = "``", disabled_filetypes = { "markdown", "md" } },
        ['"'] = { escape = true, close = true, pair = '""', disabled_filetypes = { "markdown", "md" } },
        ["'"] = { escape = true, close = true, pair = "''", disabled_filetypes = { "markdown", "md" } }
    }
})
