local lazygit = require 'dotfiles.lazygit'
local utils = require 'dotfiles.utils'

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>w', '<cmd>write<CR>', { desc = '[W]rite' })
vim.keymap.set('n', '<leader>q', '<cmd>quit<CR>', { desc = '[Q]uit' })
vim.keymap.set('n', '<leader>d', vim.diagnostic.setloclist, { desc = 'Open [D]iagnostics' })
vim.keymap.set('n', '<leader>gg', lazygit.open, { desc = 'Toggle [G]it (lazygit)' })
vim.keymap.set('n', '<leader>gf', lazygit.file_history, { desc = 'Git [F]ile history (lazygit)' })
vim.keymap.set('n', '<leader>gl', lazygit.log, { desc = 'Git [L]og (lazygit)' })
vim.keymap.set('n', '<leader>tu', '<cmd>Undotree<CR>', { desc = '[T]oggle [U]ndotree' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

for key, direction in pairs { h = 'left', j = 'lower', k = 'upper', l = 'right' } do
  vim.keymap.set('n', '<C-' .. key .. '>', '<C-w><C-' .. key .. '>', { desc = 'Focus ' .. direction .. ' window' })
end

for _, key in ipairs { '<left>', '<right>', '<up>', '<down>' } do
  vim.keymap.set('n', key, '<cmd>echo "Use hjkl to move"<CR>')
end

vim.keymap.set('n', '<leader>n', utils.new_scratch, { silent = true, desc = '[N]ew scratch buffer' })
vim.keymap.set('n', '<leader>uf', utils.copy_file_name, { desc = 'Copy [F]ile name' })
vim.keymap.set('n', '<leader>ui', utils.file_info, { desc = 'Show file [I]nfo' })
vim.keymap.set('n', '<leader>us', function()
  vim.opt_local.spell = not vim.opt_local.spell:get()
end, { desc = '[U]tils toggle [S]pell' })
vim.keymap.set('n', '<leader>ul', '<cmd>lsp restart<CR>', { desc = '[U]tils restart [L]SP' })
vim.keymap.set('n', '<leader>uL', '<cmd>checkhealth vim.lsp<CR>', { desc = '[U]tils [L]SP health' })
