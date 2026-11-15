-- Keep neo-tree (not netrw) as the directory handler so `nvim .` opens the tree.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('neo-tree').setup {
  popup_border_style = '', -- Use 'winborder' for popups.
  filesystem = {
    filtered_items = {
      hide_dotfiles = false,
      hide_by_name = { '.git', '.jj', '.DS_Store' },
    },
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
}

vim.keymap.set('n', '\\', ':Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })
