return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = "VeryLazy",
  opts = {
    options = {
      icons_enabled = true,
      theme = 'auto',
      component_separators = '|',
      section_separators = ' ',
    },
    sections = {
      lualine_c = {
        {
          'filename',
          path = 0,
          cond = function()
            return vim.bo.filetype ~= 'oil'
          end,
        },
        {
          function()
            local oil = require('oil')
            local dir = oil.get_current_dir()
            if dir then
              return vim.fn.fnamemodify(dir, ':~')
            end
            return ''
          end,
          cond = function()
            return vim.bo.filetype == 'oil'
          end,
        },
      },
    },
  },
}
