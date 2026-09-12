-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
    local ensure_installed = { 'c', 'cpp', 'go', 'helm', 'lua', 'markdown', 'markdown_inline', 'proto', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' }
    require('nvim-treesitter').install(ensure_installed)

    -- Highlighting/indent are no longer enabled via `nvim-treesitter.configs`;
    -- they're built into Neovim core and just need to be turned on per-buffer.
    local highlight_disabled = { latex = true }

    vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
            if highlight_disabled[vim.bo[args.buf].filetype] then
                return
            end
            pcall(vim.treesitter.start)
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
    })
end, 0)
