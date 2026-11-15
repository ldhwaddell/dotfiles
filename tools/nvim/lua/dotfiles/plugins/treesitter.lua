local ts = require 'nvim-treesitter'

local parsers = {
  'bash',
  'c',
  'diff',
  'git_config',
  'gitcommit',
  'gitignore',
  'html',
  'javascript',
  'json',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'python',
  'query',
  'rust',
  'sql',
  'toml',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'yaml',
}

local install = ts.install(parsers)
-- Parser installation is asynchronous. During headless bootstrap wait for it
-- so `nvim --headless +qa` leaves a fully installed tree behind. `wait` raises
-- on timeout but returns false when a parser fails to build.
if #vim.api.nvim_list_uis() == 0 and install then
  local ok, result = pcall(function()
    return install:wait(300000)
  end)
  if not ok then
    vim.notify('tree-sitter parser install failed: ' .. tostring(result), vim.log.levels.WARN)
  elseif result == false then
    vim.notify('tree-sitter parser install did not finish', vim.log.levels.WARN)
  end
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('dotfiles-treesitter', { clear = true }),
  callback = function(args)
    local language = vim.treesitter.language.get_lang(args.match) or args.match
    if not vim.treesitter.language.add(language) then
      return
    end
    vim.treesitter.start(args.buf, language)
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
