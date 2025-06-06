--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
    local create_opts = function(desc)
        if desc == '' then
            return { buffer = bufnr, remap = false }
        end
        return { desc = desc, buffer = bufnr, remap = false }
    end

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, create_opts('[G]o to [D]efinition'))
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, create_opts(''))
    vim.keymap.set('n', '<leader>dv', vim.diagnostic.open_float, create_opts('[V]iew diagnostics'))
    vim.keymap.set('n', '<leader>d[', vim.diagnostic.goto_prev, create_opts('Jump to previous diagnostic'))
    vim.keymap.set('n', '<leader>d]', vim.diagnostic.goto_next, create_opts('Jump to next diagnostic'))
    vim.keymap.set('n', '<leader>va', vim.lsp.buf.code_action, create_opts('[V]iew Code [A]ction'))
    vim.keymap.set('n', '<leader>fr', vim.lsp.buf.references, create_opts('[F]ind [R]eferences'))
    vim.keymap.set('n', '<leader>er', vim.lsp.buf.rename, create_opts('[R]ename in buffer'))
    vim.keymap.set('n', '<leader>vh', vim.lsp.buf.signature_help, create_opts('[V]iew signature [H]elp'))
    vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, create_opts('[V]iew signature [H]elp'))
    vim.keymap.set('n', '<leader>ef', vim.lsp.buf.format, { desc = '[F]ormat the current buffer with LSP' })

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })

    vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]
end

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

local servers = {
    clangd = {},
    gopls = {
        settings = {
            gopls = {
                usePlaceholders = true,
            },
        },
        filetypes = { "go", "gomod", "gowork", "gotmpl", "html" }
    },
    hls = {},
    html = { filetypes = { 'html', 'twig', 'hbs' } },
    htmx = {
        filetypes = { 'html', 'twig', 'hbs' },
    },
    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            -- diagnostics = { disable = { 'missing-fields' } },
        },
    },
    pyright = {},
    rust_analyzer = {},
    tailwindcss = {
        filetypes = { 'html', 'css', 'scss', 'javascript', 'typescript', 'vue', 'svelte' },
    },
    texlab = {},
    ts_ls = {},
}

-- Setup neovim lua configuration
-- WARNING: This might need to be changed to lazydev
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

local sourcekitCapabilities = vim.lsp.protocol.make_client_capabilities()
sourcekitCapabilities = require('cmp_nvim_lsp').default_capabilities(sourcekitCapabilities)
sourcekitCapabilities.workspace = {
    didChangeWatchedFiles = {
        dynamicRegistration = true,
    },
}

require('lspconfig').sourcekit.setup {
    capabilities = sourcekitCapabilities,
    on_attach = on_attach,
    filetypes = { 'swift' },
}

require('lspconfig').pbls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
}

capabilities.offsetEncoding = { 'utf-16' }

require("lspconfig").clangd.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = {
        "clangd",
        "--enable-config",
        "--fallback-style=microsoft",
    },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
}

vim.keymap.set('n', "<leader><leader>l", "<cmd>source ~/.config/nvim/after/plugin/lsp.lua<cr>",
    { desc = 'Reload [L]sp Settings' })
