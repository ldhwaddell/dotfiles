require('blink.cmp').setup {
  sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
  signature = { enabled = true },
}

-- Headless bootstrap: the fuzzy binary downloads asynchronously, so `+qa`
-- would exit mid-download and leave it uninstalled.
if #vim.api.nvim_list_uis() == 0 and #vim.api.nvim_get_runtime_file('target/release/libblink_cmp_fuzzy.*', false) == 0 then
  vim.wait(60000, function()
    return require('blink.cmp.fuzzy').implementation_type == 'rust'
  end, 100)
end
