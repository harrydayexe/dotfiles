require("themery").setup({
    themes = {
        {
            name = "onedarkpro",
            colorscheme = "onedark",
        },
        {
            name = "catppuccin-mocha",
            colorscheme = "catppuccin-mocha",
        },
        {
            name = "tokyonight",
            colorscheme = "tokyonight-moon",
        },
        {
            name = "rose-pine",
            colorscheme = "rose-pine-moon",
        },
    },
    livePreview = true,
})

vim.api.nvim_set_keymap('n', '<Leader>t', ':Themery<CR>', { desc = '[T]heme Switcher' })
