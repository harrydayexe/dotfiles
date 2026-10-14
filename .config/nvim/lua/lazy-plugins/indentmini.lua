return {
    'nvimdev/indentmini.nvim',
    config = function()
        -- Link to theme groups so the colours follow Themery switches
        local function set_highlights()
            vim.api.nvim_set_hl(0, 'IndentLine', { link = 'Whitespace' })
            vim.api.nvim_set_hl(0, 'IndentLineCurrent', { link = 'Comment' })
        end
        set_highlights()
        vim.api.nvim_create_autocmd('ColorScheme', { callback = set_highlights })

        require('indentmini').setup()
    end,
}
