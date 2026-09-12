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

    if vim.bo[bufnr].filetype ~= "markdown" then
        vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]
    end
end

vim.keymap.set('n', '<leader>dv', vim.diagnostic.open_float, { desc = '[V]iew diagnostics' })
vim.keymap.set('n', '<leader>d[', vim.diagnostic.goto_prev, { desc = 'Jump to previous diagnostic' })
vim.keymap.set('n', '<leader>d]', vim.diagnostic.goto_next, { desc = 'Jump to next diagnostic' })

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()

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
    html = { filetypes = { 'html', 'twig', 'hbs', 'template' } },
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

-- Configure each server, then let mason-lspconfig install and `vim.lsp.enable()` them.
for server_name, settings in pairs(servers) do
    vim.lsp.config(server_name, {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = settings,
        filetypes = settings.filetypes,
    })
end

require('mason-lspconfig').setup {
    ensure_installed = vim.tbl_keys(servers),
}

local sourcekitCapabilities = vim.lsp.protocol.make_client_capabilities()
sourcekitCapabilities = require('cmp_nvim_lsp').default_capabilities(sourcekitCapabilities)
sourcekitCapabilities.workspace = {
    didChangeWatchedFiles = {
        dynamicRegistration = true,
    },
}

vim.lsp.config('pbls', {
    capabilities = capabilities,
    on_attach = on_attach,
})
vim.lsp.enable('pbls')

capabilities.offsetEncoding = { 'utf-16' }

vim.lsp.config('clangd', {
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = {
        "clangd",
        "--enable-config",
        "--fallback-style=microsoft",
    },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
})
vim.lsp.enable('clangd')

vim.keymap.set('n', "<leader><leader>l", "<cmd>source ~/.config/nvim/after/plugin/lsp.lua<cr>",
    { desc = 'Reload [L]sp Settings' })
