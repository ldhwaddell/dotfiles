local lint = require 'lint'

lint.linters_by_ft.markdown = { 'markdownlint' }
lint.linters_by_ft.sh = { 'shellcheck' }

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
  group = vim.api.nvim_create_augroup('dotfiles-markdown-lint', { clear = true }),
  callback = function()
    lint.try_lint()
  end,
})

vim.schedule(lint.try_lint)
