local M = {}

M.new_scratch = function()
  vim.cmd 'vsplit'
  vim.cmd 'enew'
  vim.bo.buftype = 'nofile'
  vim.bo.bufhidden = 'hide'
  vim.bo.swapfile = false
end

M.copy_file_name = function()
  local name = vim.fn.expand '%:t'
  if name == nil or name == '' then
    print 'This buffer does not have a name!'
  else
    vim.fn.setreg('+', name)
    print('Copied file: ' .. name)
  end
end

return M
