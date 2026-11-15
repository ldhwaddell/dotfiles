local M = {}

local function open(args)
  if vim.fn.executable 'lazygit' == 0 then
    vim.notify('lazygit is not installed', vim.log.levels.WARN)
    return
  end

  local width, height = math.floor(vim.o.columns * 0.9), math.floor(vim.o.lines * 0.85)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.keymap.set('t', '<Esc>', '<Esc>', { buffer = buf, nowait = true, desc = 'Pass Esc to lazygit' })
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
  })

  local job = vim.api.nvim_buf_call(buf, function()
    return vim.fn.jobstart(vim.list_extend({ 'lazygit' }, args or {}), {
      term = true,
      on_exit = function(_, code)
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
          if code ~= 0 then
            vim.notify(('lazygit exited with code %d'):format(code), vim.log.levels.ERROR)
          end
        elseif vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
        if vim.v.exiting == 0 then
          vim.cmd 'silent! checktime'
          pcall(function()
            require('gitsigns').refresh()
          end)
          if package.loaded['neo-tree'] then
            pcall(function()
              require('neo-tree.events').fire_event 'git_event'
            end)
          end
        end
      end,
    })
  end)

  if job <= 0 then
    vim.notify('Failed to start lazygit', vim.log.levels.ERROR)
    vim.api.nvim_win_close(win, true)
    return
  end
  vim.cmd 'startinsert'
end

M.open = open

function M.file_history()
  local name = vim.api.nvim_buf_get_name(0)
  if name == '' or vim.bo.buftype ~= '' then
    vim.notify('The current buffer has no file to filter lazygit by', vim.log.levels.WARN)
    return
  end
  open { '-f', vim.fs.normalize(name) }
end

function M.log()
  open { 'log' }
end

return M
