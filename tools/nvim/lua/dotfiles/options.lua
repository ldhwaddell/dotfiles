-- Experimental new cmdline/message UI (see :h ui2).
require('vim._core.ui2').enable {}

vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = ''
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 15
vim.o.confirm = true
vim.o.winborder = 'rounded'
vim.o.pumborder = 'rounded'
vim.o.laststatus = 3
vim.o.showbreak = '↳ '
vim.opt.jumpoptions:append 'view'
vim.opt.diffopt:append 'algorithm:histogram'

vim.o.clipboard = 'unnamedplus'

vim.diagnostic.config {
  severity_sort = true,
  float = { source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text = true,
  jump = {
    on_jump = function()
      vim.schedule(function()
        vim.diagnostic.open_float { scope = 'cursor', focus = false }
      end)
    end,
  },
}
