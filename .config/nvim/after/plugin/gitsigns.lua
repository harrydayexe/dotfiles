require('gitsigns').setup {
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        -- Navigation
        vim.keymap.set('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function()
                gs.next_hunk()
            end)
            return '<Ignore>'
        end, { buffer = bufnr, desc = 'Next hunk' })

        vim.keymap.set('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function()
                gs.prev_hunk()
            end)
            return '<Ignore>'
        end, { buffer = bufnr, desc = 'Previous hunk' })

        -- Actions
        vim.keymap.set('n', '<leader>gs', gs.stage_hunk, { buffer = bufnr, desc = '[s]tage hunk' })
        vim.keymap.set('n', '<leader>gS', gs.stage_buffer, { buffer = bufnr, desc = '[S]tage buffer' })
        vim.keymap.set('n', '<leader>gu', gs.undo_stage_hunk, { buffer = bufnr, desc = '[u]ndo stage hunk' })
        vim.keymap.set('n', '<leader>gr', gs.reset_hunk, { buffer = bufnr, desc = '[r]eset hunk' })
        vim.keymap.set('n', '<leader>gR', gs.reset_buffer, { buffer = bufnr, desc = '[R]eset buffer' })
        vim.keymap.set('n', '<leader>gp', gs.preview_hunk, { buffer = bufnr, desc = '[p]review hunk' })
        vim.keymap.set('n', '<leader>gb', gs.blame_line, { buffer = bufnr, desc = '[b]lame line' })
        vim.keymap.set('n', '<leader>gt', gs.toggle_current_line_blame, { buffer = bufnr, desc = '[t]oggle line blame' })
        vim.keymap.set('n', '<leader>gd', gs.diffthis, { buffer = bufnr, desc = '[d]iff' })
    end
}
