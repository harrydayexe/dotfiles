require("jupytext").setup({
    style = "myst",
    output_extension = "md",
    force_ft = "markdown",
})

local minimal_ipynb = [[{
 "cells": [],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "name": "python",
   "version": "3.0.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}]]

vim.api.nvim_create_user_command("NewNotebook", function(opts)
    local path = opts.args
    if not path:match("%.ipynb$") then
        path = path .. ".ipynb"
    end
    local file = io.open(path, "w")
    if file then
        file:write(minimal_ipynb)
        file:close()
        vim.cmd("edit " .. vim.fn.fnameescape(path))
    else
        vim.notify("NewNotebook: could not create " .. path, vim.log.levels.ERROR)
    end
end, { nargs = 1, desc = "Create and open a new Jupyter notebook" })

vim.keymap.set("n", "<leader>jn", ":NewNotebook ",
    { desc = "[J]upyter [N]ew notebook", noremap = true })
