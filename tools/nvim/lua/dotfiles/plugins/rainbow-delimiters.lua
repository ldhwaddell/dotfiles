local rainbow = require 'rainbow-delimiters'

vim.g.rainbow_delimiters = {
  strategy = { vim = rainbow.strategy['local'] },
  query = { lua = 'rainbow-blocks' },
  priority = { [''] = 110, lua = 210 },
}
