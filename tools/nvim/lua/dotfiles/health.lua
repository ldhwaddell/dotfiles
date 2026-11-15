local M = {}

local function check_executables(title, executables)
  vim.health.start(title)
  for _, executable in ipairs(executables) do
    local path = vim.fn.exepath(executable)
    if path == '' then
      vim.health.error(('Missing executable: %s (install via Brewfile)'):format(executable))
    else
      vim.health.ok(('%s: %s'):format(executable, path))
    end
  end
end

function M.check()
  vim.health.start 'dotfiles'

  if vim.fn.has 'nvim-0.12' == 1 then
    vim.health.ok(('Neovim %s'):format(tostring(vim.version())))
  else
    vim.health.error(('Neovim 0.12.0+ required; found %s'):format(tostring(vim.version())))
  end

  check_executables('System tools', { 'git', 'make', 'unzip', 'rg', 'tree-sitter', 'ast-grep', 'rustup', 'rustc', 'cargo', 'rustfmt', 'fzf', 'fd', 'lazygit' })
  check_executables(
    'Neovim tools',
    { 'lua-language-server', 'stylua', 'tsc', 'oxlint', 'oxfmt', 'ruff', 'ty', 'markdownlint', 'mdformat', 'sql-formatter', 'rust-analyzer', 'shellcheck' }
  )
end

return M
