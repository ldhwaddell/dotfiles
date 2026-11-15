local function gh(repo)
  return 'https://github.com/' .. repo
end

-- Must be created before the first `vim.pack` call so hooks also run for
-- plugins installed from the lockfile during `vim.pack.add()`.
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name ~= 'nvim-treesitter' or (kind ~= 'install' and kind ~= 'update') then
      return
    end
    -- `:TSUpdate` needs the plugin's user commands, so load it first when the
    -- change happened outside of the current session.
    if not ev.data.active then
      vim.cmd.packadd 'nvim-treesitter'
    end
    vim.cmd 'TSUpdate'
  end,
})

vim.pack.add({
  { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' },
  { src = gh 'ibhagwan/fzf-lua' },
  { src = gh 'neovim/nvim-lspconfig', version = vim.version.range '2.*' },
  { src = gh 'stevearc/conform.nvim' },
  { src = gh 'mfussenegger/nvim-lint' },
  { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' },
  { src = gh 'lewis6991/gitsigns.nvim', version = vim.version.range '2.*' },
  { src = gh 'folke/tokyonight.nvim', version = vim.version.range '4.*' },
  { src = gh 'folke/which-key.nvim', version = vim.version.range '3.*' },
  { src = gh 'lukas-reineke/indent-blankline.nvim', version = vim.version.range '3.*' },
  { src = gh 'NMAC427/guess-indent.nvim' },
  { src = gh 'HiPhish/rainbow-delimiters.nvim', version = vim.version.range '0.*' },
  { src = gh 'MeanderingProgrammer/render-markdown.nvim', version = vim.version.range '8.*' },
  { src = gh 'nvim-mini/mini.nvim', version = 'main' },
  { src = gh 'nvim-neo-tree/neo-tree.nvim', version = vim.version.range '3.*' },
  { src = gh 'MunifTanjim/nui.nvim', version = vim.version.range '0.*' },
  { src = gh 'nvim-lua/plenary.nvim', version = vim.version.range '0.*' },
}, { confirm = false })

vim.cmd.packadd 'nvim.undotree'
vim.cmd.packadd 'nvim.difftool'

vim.keymap.set('n', '<leader>up', vim.pack.update, { desc = '[U]pdate [P]lugins' })
vim.keymap.set('n', '<leader>uR', '<cmd>restart<CR>', { desc = '[U]tils [R]estart Neovim' })
