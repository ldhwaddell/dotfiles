vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require 'dotfiles.options'
require 'dotfiles.keymaps'
require 'dotfiles.autocmds'
require 'dotfiles.pack'

-- Load order matters: colorscheme, then mini.icons, then blink (its
-- capabilities feed lsp).
require 'dotfiles.plugins.tokyonight'
require 'dotfiles.plugins.mini'
require 'dotfiles.plugins.blink'
require 'dotfiles.plugins.lsp'
require 'dotfiles.plugins.fzf-lua'
require 'dotfiles.plugins.which-key'
require 'dotfiles.plugins.treesitter'
require 'dotfiles.plugins.gitsigns'
require 'dotfiles.plugins.conform'
require 'dotfiles.plugins.lint'
require 'dotfiles.plugins.neo-tree'
require 'dotfiles.plugins.indent-blankline'
require 'dotfiles.plugins.guess-indent'
require 'dotfiles.plugins.rainbow-delimiters'
require 'dotfiles.plugins.render-markdown'

-- vim: ts=2 sts=2 sw=2 et
