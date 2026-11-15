require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    if vim.tbl_contains({ 'c', 'cpp' }, vim.bo[bufnr].filetype) then
      return
    end
    return { timeout_ms = 1000, lsp_format = 'fallback' }
  end,
  formatters_by_ft = {
    lua = { 'stylua' },
    markdown = { 'mdformat' },
    typescript = { 'oxfmt' },
    typescriptreact = { 'oxfmt' },
    javascript = { 'oxfmt' },
    javascriptreact = { 'oxfmt' },
    json = { 'oxfmt' },
    html = { 'oxfmt' },
    sql = { 'sql_formatter' },
    python = { 'ruff_format', 'ruff_organize_imports' },
    rust = { 'rustfmt' },
  },
}

vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
  require('conform').format { async = true, lsp_format = 'fallback' }
end, { desc = '[F]ormat buffer' })
