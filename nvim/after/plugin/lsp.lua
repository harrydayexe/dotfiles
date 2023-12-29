--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
    local create_opts = function(desc)
        if desc == '' then
            return { buffer = bufnr, remap = false }
        end
        return { desc = desc, buffer = bufnr, remap = false }
    end

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, create_opts('[G]o to [D]eclaration'))
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, create_opts(''))
    vim.keymap.set('n', '<leader>fws', vim.lsp.buf.workspace_symbol, create_opts('[F]ind [W]orkspace [S]ymbol'))
    vim.keymap.set('n', '<leader>dv', vim.diagnostic.open_float, create_opts('[V]iew diagnostics'))
    vim.keymap.set('n', '<leader>d[', vim.diagnostic.goto_prev, create_opts('Jump to previous diagnostic'))
    vim.keymap.set('n', '<leader>d]', vim.diagnostic.goto_next, create_opts('Jump to next diagnostic'))
    vim.keymap.set('n', '<leader>va', vim.lsp.buf.code_action, create_opts('[V]iew Code [A]ction'))
    vim.keymap.set('n', '<leader>vr', vim.lsp.buf.references, create_opts('[V]iew [R]eferences'))
    vim.keymap.set('n', '<leader>er', vim.lsp.buf.rename, create_opts('[R]ename in buffer'))
    vim.keymap.set('n', '<leader>vh', vim.lsp.buf.signature_help, create_opts('[V]iew signature [H]elp'))
    vim.keymap.set('n', '<leader>ef', vim.lsp.buf.format, { desc = '[F]ormat the current buffer with LSP' })

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
end

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

local servers = {
    clangd = {},
    gopls = {},
    pyright = {},
    rust_analyzer = {},
    tsserver = {},
    html = { filetypes = { 'html', 'twig', 'hbs' } },

    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            -- diagnostics = { disable = { 'missing-fields' } },
        },
    },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
    function(server_name)
        require('lspconfig')[server_name].setup {
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name],
            filetypes = (servers[server_name] or {}).filetypes,
        }
    end,
}
