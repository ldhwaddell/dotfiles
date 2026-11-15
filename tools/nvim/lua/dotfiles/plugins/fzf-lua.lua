local fzf = require 'fzf-lua'

-- file_icons and rg_glob each spawn a helper nvim per picker (and per
-- live_grep keystroke).
fzf.setup {
  files = { file_icons = false },
  grep = {
    file_icons = false,
    rg_glob = false,
    rg_opts = '--hidden -g !.git -g !.jj --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e',
  },
}
fzf.register_ui_select()

vim.keymap.set('n', '<leader>sh', fzf.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', fzf.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', fzf.files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', fzf.builtin, { desc = '[S]earch [S]elect picker' })
vim.keymap.set('n', '<leader>sw', fzf.grep_cword, { desc = '[S]earch current [W]ord' })
vim.keymap.set('v', '<leader>sw', fzf.grep_visual, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', fzf.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', fzf.diagnostics_workspace, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', fzf.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', fzf.oldfiles, { desc = '[S]earch recent files' })
vim.keymap.set('n', '<leader>sc', fzf.commands, { desc = '[S]earch [C]ommands' })
vim.keymap.set('n', '<leader><leader>', fzf.buffers, { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>/', fzf.blines, { desc = 'Search current buffer' })
vim.keymap.set('n', '<leader>s/', function()
  local paths = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if vim.bo[buf].buflisted and name ~= '' then
      paths[#paths + 1] = name
    end
  end
  fzf.live_grep { search_paths = paths }
end, { desc = '[S]earch open files' })
vim.keymap.set('n', '<leader>sn', function()
  fzf.files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })
vim.keymap.set('n', '<leader>s"', fzf.registers, { desc = '[S]earch registers' })
vim.keymap.set('n', '<leader>sm', fzf.marks, { desc = '[S]earch [M]arks' })
vim.keymap.set('n', '<leader>sj', fzf.jumps, { desc = '[S]earch [J]umps' })
vim.keymap.set('n', '<leader>s:', fzf.command_history, { desc = '[S]earch command history' })
vim.keymap.set('n', '<leader>sq', fzf.quickfix_stack, { desc = '[S]earch [Q]uickfix stack' })
