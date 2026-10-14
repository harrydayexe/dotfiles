return {
    'folke/twilight.nvim',
    opts = {},
    config = function(_, opts)
        require("twilight").setup(opts)
        -- Twilight sets an explicit guibg on dimmed lines, which renders
        -- slightly differently from plain Normal cells. It (re)defines the
        -- group in config.colors() on enable and on ColorScheme, so wrap
        -- that to drop the background each time.
        local config = require("twilight.config")
        local colors = config.colors
        config.colors = function()
            colors()
            local hl = vim.api.nvim_get_hl(0, { name = "Twilight", link = false })
            hl.bg = nil
            vim.api.nvim_set_hl(0, "Twilight", hl)
        end
    end,
}
