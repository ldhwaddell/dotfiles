require('which-key').setup {
  delay = 0,
  spec = {
    { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
    { '<leader>g', group = 'Git', mode = { 'n', 'v' } },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>u', group = '[U]tils' },
    { 'gr', group = 'LSP Actions', mode = 'n' },
  },
}
