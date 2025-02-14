return {
    "lervag/vimtex",
    lazy = false, -- we don't want to lazy load VimTeX
    init = function()
        -- VimTeX configuration goes here, e.g.
        vim.g.vimtex_view_method = "skim"
        vim.g.vimtex_view_enabled = 1
        vim.g.vimtex_mappings_prefix = "<leader>v"
    end
}
