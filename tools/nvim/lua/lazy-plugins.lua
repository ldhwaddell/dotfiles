require('lazy').setup({

  'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically
  require 'plugins.autopairs',
  require 'plugins.blink-cmp',
  require 'plugins.conform',
  require 'plugins.gitsigns',
  require 'plugins.indent-line',
  require 'plugins.lazygit',
  require 'plugins.lint',
  require 'plugins.lsp-config',
  require 'plugins.mini',
  require 'plugins.neo-tree',
  require 'plugins.rainbow-delimiters',
  require 'plugins.render-markdown',
  require 'plugins.telescope',
  require 'plugins.theme',
  require 'plugins.todo-comments',
  require 'plugins.treesitter',
  require 'plugins.which-key',

  --
  -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
  -- Or use telescope!
  -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
  -- you can continue same window with `<space>sr` which resumes last telescope search
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
