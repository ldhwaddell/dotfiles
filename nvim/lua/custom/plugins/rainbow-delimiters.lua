return {
  'HiPhish/rainbow-delimiters.nvim',
  -- ft = { 'scheme' }, -- Load only for Scheme files
  config = function()
    local rainbow_delimiters = require 'rainbow-delimiters'

    vim.g.rainbow_delimiters = {
      strategy = {
        [''] = rainbow_delimiters.strategy['global'],
        vim = rainbow_delimiters.strategy['local'],
      },
      query = {
        [''] = 'rainbow-delimiters',
        lua = 'rainbow-blocks',
      },
      priority = {
        [''] = 110,
        lua = 210,
      },
      highlight = {
        'RainbowDelimiterRed',
        'RainbowDelimiterYellow',
        'RainbowDelimiterBlue',
        'RainbowDelimiterOrange',
        'RainbowDelimiterGreen',
        'RainbowDelimiterViolet',
        'RainbowDelimiterCyan',
      },
    }
    -- vim.g.rainbow_delimiters = {
    --   strategy = {
    --     scheme = rainbow_delimiters.strategy['global'],
    --   },
    --   query = {
    --     scheme = 'rainbow-delimiters',
    --   },
    --   highlight = {
    --     'RainbowDelimiterRed',
    --     'RainbowDelimiterYellow',
    --     'RainbowDelimiterBlue',
    --     'RainbowDelimiterOrange',
    --     'RainbowDelimiterGreen',
    --     'RainbowDelimiterViolet',
    --     'RainbowDelimiterCyan',
    --   },
    -- }
  end,
}
