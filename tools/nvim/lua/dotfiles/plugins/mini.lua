require('mini.ai').setup { n_lines = 500 }
require('mini.surround').setup()
require('mini.pairs').setup()
require('mini.move').setup()
require('mini.align').setup()

require('mini.icons').setup()
require('mini.icons').mock_nvim_web_devicons()

local statusline = require 'mini.statusline'
statusline.setup()
statusline.section_location = function()
  return '%2l:%-2v'
end

require('mini.hipatterns').setup {
  highlighters = {
    fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
    hack = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
    todo = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
    note = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },
    hex_color = require('mini.hipatterns').gen_highlighter.hex_color(),
  },
}
