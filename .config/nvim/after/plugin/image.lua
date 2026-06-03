require("image").setup({
    backend = "kitty",
    processor = "magick_rock",
    integrations = {
        markdown = {
            enabled = true,
            only_render_image_at_cursor = false,
            filetypes = { "markdown", "quarto" },
        },
    },
    max_width = 100,
    max_height = 12,
    max_height_window_percentage = 50,
})
