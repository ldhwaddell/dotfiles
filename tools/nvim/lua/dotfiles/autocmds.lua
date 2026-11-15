vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('dotfiles-highlight-yank', { clear = true }),
  desc = 'Highlight yanked text',
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('dotfiles-prose', { clear = true }),
  pattern = { 'gitcommit', 'markdown' },
  callback = function(args)
    vim.opt_local.spell = true
    if args.match == 'gitcommit' then
      vim.opt_local.colorcolumn = '73'
    end
  end,
})
