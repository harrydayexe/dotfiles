require("carbon-now").setup({
    base_url = "https://carbon.now.sh/",
    options = {
        bg = "rgba(175,224,230,1)",
        drop_shadow_blur = "68px",
        drop_shadow = true,
        drop_shadow_offset_y = "20px",
        font_family = "Hack",
        font_size = "14px",
        line_height = "133%",
        line_numbers = false,
        theme = "one-dark",
        titlebar = "",
        watermark = false,
        width = "680",
        window_theme = "none",
        padding_horizontal = "56px",
        padding_vertical = "56px",
    },
})

vim.keymap.set("v", "<leader>cn", ":CarbonNow<CR>", { desc = "[C]arbon [N]ow", silent = true })
