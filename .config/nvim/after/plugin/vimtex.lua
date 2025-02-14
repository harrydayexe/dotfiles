vim.api.nvim_create_autocmd("User", {
    pattern = "VimtexEventViewReverse",
    callback = function()
        vim.fn.system("open -a iTerm")
        vim.cmd("redraw!")
    end,
    group = vim.api.nvim_create_augroup("vimtex_event_focus", { clear = true }),
})
