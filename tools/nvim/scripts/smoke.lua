local lsp_expectations = {
  lua = { 'lua_ls', 'stylua' },
  python = { 'ruff', 'ty' },
  typescript = { 'tsc', 'oxlint' },
  rust = { 'rust_analyzer' },
}

local treesitter_expectations = {
  lua = 'lua',
  python = 'python',
  typescript = 'typescript',
  typescriptreact = 'tsx',
  javascript = 'javascript',
  rust = 'rust',
  markdown = 'markdown',
  json = 'json',
  sql = 'sql',
  sh = 'bash',
  html = 'html',
  yaml = 'yaml',
  toml = 'toml',
  vim = 'vim',
  gitcommit = 'gitcommit',
}

local conform_filetypes = {
  'lua',
  'python',
  'typescript',
  'javascript',
  'json',
  'html',
  'markdown',
  'sql',
  'rust',
}

local mode = vim.env.SMOKE_MODE or 'filetype'
local results = {}

local function record(status, name, detail)
  results[#results + 1] = { status = status, name = name, detail = detail }
end

local function join(values)
  return table.concat(values, ', ')
end

local function lsp_names(buf)
  local names = {}
  for _, client in ipairs(vim.lsp.get_clients { bufnr = buf }) do
    names[#names + 1] = client.name
  end
  table.sort(names)
  return names
end

local function wait_for_clients(buf, expected, timeout)
  return vim.wait(timeout, function()
    local present = {}
    for _, name in ipairs(lsp_names(buf)) do
      present[name] = true
    end
    for _, name in ipairs(expected) do
      if not present[name] then
        return false
      end
    end
    return true
  end, 100)
end

local function messages_problem()
  local problems = {}
  for line in vim.fn.execute('messages'):gmatch '[^\n]+' do
    if line:find('Error', 1, true) or line:find 'E%d+:' then
      problems[#problems + 1] = vim.trim(line)
    end
  end
  return problems
end

local function check_messages(name)
  local problems = messages_problem()
  if #problems == 0 then
    record('PASS', 'messages ' .. name)
  else
    record('FAIL', 'messages ' .. name, join(problems))
  end
end

local function check_lsp(buf, ft)
  local expected = lsp_expectations[ft]
  if not expected then
    return
  end
  if wait_for_clients(buf, expected, 15000) then
    record('PASS', 'lsp ' .. ft, join(expected))
  else
    record('FAIL', 'lsp ' .. ft, ('expected %s, got %s'):format(join(expected), join(lsp_names(buf))))
  end
end

local function active_treesitter_language(buf)
  local highlighter = vim.treesitter.highlighter.active[buf]
  if highlighter and highlighter.tree then
    return highlighter.tree:lang()
  end
end

local function check_treesitter(buf, ft)
  local language = treesitter_expectations[ft]
  if not language then
    return
  end
  local active = vim.wait(2000, function()
    return active_treesitter_language(buf) == language
  end, 50)
  if active then
    record('PASS', 'treesitter ' .. ft, language)
  else
    local got = active_treesitter_language(buf) or 'no active highlighter'
    record('FAIL', 'treesitter ' .. ft, ('expected %s, got %s'):format(language, got))
  end
end

local function check_conform(buf, ft)
  if not vim.tbl_contains(conform_filetypes, ft) then
    return
  end
  local ok, conform = pcall(require, 'conform')
  if not ok then
    record('FAIL', 'conform ' .. ft, 'conform module unavailable')
    return
  end
  local names, unavailable = {}, {}
  for _, formatter in ipairs(conform.list_formatters_to_run(buf)) do
    names[#names + 1] = formatter.name
    if not formatter.available then
      unavailable[#unavailable + 1] = formatter.name
    end
  end
  if #names > 0 and #unavailable == 0 then
    record('PASS', 'conform ' .. ft, join(names))
  elseif #names == 0 then
    record('FAIL', 'conform ' .. ft, 'no formatters resolved')
  else
    record('FAIL', 'conform ' .. ft, 'unavailable: ' .. join(unavailable))
  end
end

local function check_prose(ft)
  if ft == 'markdown' or ft == 'gitcommit' then
    if vim.wo.spell then
      record('PASS', 'spell ' .. ft)
    else
      record('FAIL', 'spell ' .. ft, 'spell is off')
    end
  end
  if ft == 'gitcommit' then
    if vim.wo.colorcolumn == '73' then
      record('PASS', 'colorcolumn gitcommit', vim.wo.colorcolumn)
    else
      record('FAIL', 'colorcolumn gitcommit', ('expected 73, got %s'):format(vim.wo.colorcolumn))
    end
    if vim.bo.textwidth == 72 then
      record('PASS', 'textwidth gitcommit', tostring(vim.bo.textwidth))
    else
      record('FAIL', 'textwidth gitcommit', ('expected 72, got %s'):format(tostring(vim.bo.textwidth)))
    end
  end
end

local function check_lint(ft)
  if ft ~= 'sh' then
    return
  end
  local linters = require('lint').linters_by_ft.sh or {}
  if vim.tbl_contains(linters, 'shellcheck') then
    record('PASS', 'lint sh', 'shellcheck')
  else
    record('FAIL', 'lint sh', ('expected shellcheck, got %s'):format(join(linters)))
  end
end

local function check_filetype()
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  local expected_ft = vim.env.SMOKE_FT
  if expected_ft and ft ~= expected_ft then
    record('FAIL', 'filetype ' .. expected_ft, 'got ' .. ft)
    return
  end
  check_lsp(buf, ft)
  check_treesitter(buf, ft)
  check_conform(buf, ft)
  check_prose(ft)
  check_lint(ft)
  check_messages(ft)
end

local function run_health(target)
  vim.cmd('silent checkhealth ' .. target)
  return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

local function check_health_target(target)
  local ok, lines = pcall(run_health, target)
  if not ok then
    record('FAIL', 'health ' .. target, tostring(lines))
    return
  end
  local errors = {}
  for _, line in ipairs(lines) do
    if line:find('ERROR', 1, true) then
      errors[#errors + 1] = vim.trim(line)
    end
  end
  if #errors == 0 then
    record('PASS', 'health ' .. target)
  else
    record('FAIL', 'health ' .. target, join(errors))
  end
end

local function check_health()
  check_health_target 'dotfiles'
  check_health_target 'vim.lsp'
  local ok, plugins = pcall(function()
    return vim.pack.get()
  end)
  if ok and #plugins > 0 then
    check_health_target 'vim.pack'
  else
    record('SKIP', 'health vim.pack', 'no plugins managed by vim.pack')
  end
end

local function check_startup_messages()
  check_messages 'startup'
end

local function check_blink_fuzzy()
  local ok, fuzzy = pcall(require, 'blink.cmp.fuzzy')
  if not ok then
    record('FAIL', 'blink fuzzy', tostring(fuzzy))
    return
  end
  local ready = vim.wait(10000, function()
    return fuzzy.implementation_type == 'rust'
  end, 100)
  if ready then
    record('PASS', 'blink fuzzy', 'rust')
  else
    record('FAIL', 'blink fuzzy', ('expected rust, got %s'):format(tostring(fuzzy.implementation_type)))
  end
end

local function check_harness()
  local source = debug.getinfo(1, 'S').source:sub(2)
  local expected = vim.uv.fs_realpath(vim.fn.fnamemodify(source, ':p:h:h'))
  local config = vim.uv.fs_realpath(vim.fn.stdpath 'config')
  if expected and config and expected == config then
    record('PASS', 'harness config path', config)
  else
    record('FAIL', 'harness config path', ('expected %s, got %s'):format(tostring(expected), tostring(config)))
  end
end

local function check_keymaps()
  local expected = {
    ['<leader>gg'] = 'Toggle [G]it (lazygit)',
    ['<leader>gf'] = 'Git [F]ile history (lazygit)',
    ['<leader>gl'] = 'Git [L]og (lazygit)',
    ['<leader>tu'] = '[T]oggle [U]ndotree',
    ['<leader>s"'] = '[S]earch registers',
    ['<leader>sm'] = '[S]earch [M]arks',
    ['<leader>sj'] = '[S]earch [J]umps',
    ['<leader>s:'] = '[S]earch command history',
    ['<leader>sq'] = '[S]earch [Q]uickfix stack',
    ['<leader>us'] = '[U]tils toggle [S]pell',
    ['<leader>ul'] = '[U]tils restart [L]SP',
    ['<leader>uL'] = '[U]tils [L]SP health',
    ['<leader>up'] = '[U]pdate [P]lugins',
    ['<leader>uR'] = '[U]tils [R]estart Neovim',
  }
  for lhs, desc in pairs(expected) do
    local map = vim.fn.maparg(lhs, 'n', false, true)
    if map.desc == desc then
      record('PASS', 'keymap ' .. lhs, desc)
    else
      record('FAIL', 'keymap ' .. lhs, ('expected %s, got %s'):format(desc, tostring(map.desc)))
    end
  end
end

local function check_mini()
  for _, name in ipairs { 'MiniMove', 'MiniAlign' } do
    if type(_G[name]) == 'table' then
      record('PASS', 'global ' .. name)
    else
      record('FAIL', 'global ' .. name, ('expected table, got %s'):format(type(_G[name])))
    end
  end
  local highlighters = require('mini.hipatterns').config.highlighters
  if highlighters.hex_color then
    record('PASS', 'hipatterns hex_color')
  else
    record('FAIL', 'hipatterns hex_color', 'not configured')
  end
end

local function check_lazygit()
  local lg = require 'dotfiles.lazygit'

  local function find_float()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(win).relative ~= '' then
        return win
      end
    end
  end

  local function job_running(job)
    return vim.fn.jobwait({ job }, 0)[1] == -1
  end

  local function check(name, ok, detail)
    record(ok and 'PASS' or 'FAIL', name, not ok and detail or nil)
  end

  check_keymaps()

  lg.open()
  local win = find_float()
  if not win then
    record('FAIL', 'lazygit float open', 'no float window')
    return
  end
  local buf = vim.api.nvim_win_get_buf(win)
  local job = vim.b[buf].terminal_job_id
  check('lazygit float open', true)
  check('lazygit terminal buffer', vim.bo[buf].buftype == 'terminal', vim.bo[buf].buftype)
  check('lazygit job running', job ~= nil and job_running(job), tostring(job))

  local esc
  for _, map in ipairs(vim.api.nvim_buf_get_keymap(buf, 't')) do
    if map.lhs == '<Esc>' then
      esc = map
    end
  end
  check('lazygit buffer <Esc> nowait', esc and esc.nowait == 1 and esc.rhs == '<Esc>', esc and esc.rhs or 'missing')

  vim.api.nvim_win_close(win, true)
  check(
    'lazygit close stops job',
    vim.wait(5000, function()
      return not job_running(job)
    end, 50),
    'still running'
  )
  check('lazygit close wipes buffer', not vim.api.nvim_buf_is_valid(buf), 'buffer still valid')

  vim.env.LAZYGIT_STUB_EXIT = '0'
  lg.open()
  local exit_win = find_float()
  local exit_buf = exit_win and vim.api.nvim_win_get_buf(exit_win)
  vim.env.LAZYGIT_STUB_EXIT = nil
  check(
    'lazygit exit cleans up',
    vim.wait(5000, function()
      return exit_buf ~= nil and not vim.api.nvim_win_is_valid(exit_win) and not vim.api.nvim_buf_is_valid(exit_buf)
    end, 50),
    'window or buffer still present'
  )

  vim.env.LAZYGIT_STUB_EXIT = '2'
  local captured = {}
  local original_notify = vim.notify
  vim.notify = function(message, level)
    captured[#captured + 1] = { message = message, level = level }
  end
  lg.open()
  local notified = vim.wait(5000, function()
    return #captured > 0
  end, 50)
  vim.notify = original_notify
  vim.env.LAZYGIT_STUB_EXIT = nil
  local failure = captured[1] or {}
  check('lazygit failure notifies', notified and failure.message:find('lazygit exited with code 2', 1, true) ~= nil, failure.message or '')
  check('lazygit failure level', failure.level == vim.log.levels.ERROR, tostring(failure.level))
end

local function check_lsp_progress()
  local events = {}
  local group = vim.api.nvim_create_augroup('dotfiles-smoke-progress', { clear = true })
  vim.api.nvim_create_autocmd('Progress', {
    group = group,
    callback = function(ev)
      if ev.data.source == 'vim.lsp' then
        events[#events + 1] = ev.data
      end
    end,
  })

  local function fire(client_id, token, kind, message, percentage, title)
    vim.api.nvim_exec_autocmds('LspProgress', {
      data = {
        client_id = client_id,
        params = {
          token = token,
          value = { kind = kind, message = message, percentage = percentage, title = title },
        },
      },
    })
  end

  -- Headless Nvim echoes progress to stdout; drop progress:c to keep it quiet.
  local saved_messagesopt = vim.o.messagesopt
  vim.o.messagesopt = 'hit-enter,history:500'

  -- Same token from two clients, plus a second token: all must collapse to one id.
  fire(1, 1, 'begin', 'Loading workspace', 0, 'Loading workspace')
  fire(2, 1, 'begin', 'Checking files', 0, 'Checking files')
  fire(1, 2, 'begin', 'Diagnosing', nil, 'Diagnosing')
  fire(1, 1, 'report', 'Loading workspace', 42, 'Loading workspace')
  fire(2, 1, 'report', 'Checking files', 60, 'Checking files')
  fire(1, 2, 'report', 'Diagnosing', 30, 'Diagnosing')
  fire(1, 1, 'end', nil, nil, 'Loading workspace')
  fire(2, 1, 'end', nil, nil, 'Checking files')
  fire(1, 2, 'end', nil, nil, 'Diagnosing')

  vim.o.messagesopt = saved_messagesopt
  vim.api.nvim_clear_autocmds { group = group }

  local ids, running, success = {}, 0, 0
  for _, event in ipairs(events) do
    ids[event.id] = true
    if event.status == 'running' then
      running = running + 1
    elseif event.status == 'success' then
      success = success + 1
    end
  end
  local function event_text(event)
    if type(event.text) == 'string' then
      return event.text
    end
    return table.concat(event.text or {}, '')
  end
  local id_count = vim.tbl_count(ids)
  record(id_count == 1 and 'PASS' or 'FAIL', 'lsp progress id', ('%d distinct ids'):format(id_count))
  record(running > 0 and 'PASS' or 'FAIL', 'lsp progress running', tostring(running))
  record(success > 0 and 'PASS' or 'FAIL', 'lsp progress success', tostring(success))
  local last = events[#events]
  record(last and last.status == 'success' and 'PASS' or 'FAIL', 'lsp progress final', last and tostring(last.status) or 'no events')
  record(last and event_text(last) == 'done' and 'PASS' or 'FAIL', 'lsp progress text', last and event_text(last) or 'no events')
end

local function check_ui()
  for _, option in ipairs { 'winborder', 'pumborder' } do
    local value = vim.o[option]
    if value == 'rounded' then
      record('PASS', option, value)
    else
      record('FAIL', option, ('expected rounded, got %s'):format(value))
    end
  end
end

local function check_commands()
  for _, name in ipairs { 'Undotree', 'DiffTool' } do
    if vim.fn.exists(':' .. name) == 2 then
      record('PASS', 'command ' .. name)
    else
      record('FAIL', 'command ' .. name, 'not available')
    end
  end
end

local function check_startup()
  check_ui()
  check_commands()
  check_keymaps()
  check_mini()
  check_blink_fuzzy()
  check_lsp_progress()
  check_startup_messages()
end

local function check_neotree()
  local found = vim.wait(5000, function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'neo-tree' then
        return true
      end
    end
    return false
  end, 100)
  if found then
    record('PASS', 'neo-tree window')
  else
    record('FAIL', 'neo-tree window', 'no neo-tree window after 5s')
  end
end

local function check_gitmaps()
  local leader = vim.g.mapleader or '\\'
  local expected = {
    n = {
      [']c'] = 'Jump to next git [c]hange',
      ['[c'] = 'Jump to previous git [c]hange',
      [leader .. 'gs'] = 'Git [s]tage hunk',
      [leader .. 'gr'] = 'Git [r]eset hunk',
      [leader .. 'gS'] = 'Git [S]tage buffer',
      [leader .. 'gu'] = 'Git [u]ndo stage hunk',
      [leader .. 'gR'] = 'Git [R]eset buffer',
      [leader .. 'gp'] = 'Git [p]review hunk',
      [leader .. 'gb'] = 'Git [b]lame line',
      [leader .. 'gd'] = 'Git [d]iff against index',
      [leader .. 'gD'] = 'Git [D]iff against last commit',
      [leader .. 'tb'] = '[T]oggle git show [b]lame line',
      [leader .. 'tD'] = '[T]oggle git show [D]eleted',
    },
    v = {
      [leader .. 'gs'] = 'Git [s]tage hunk',
      [leader .. 'gr'] = 'Git [r]eset hunk',
    },
  }

  local function buffer_maps(mode_name)
    local maps = {}
    for _, map in ipairs(vim.api.nvim_buf_get_keymap(0, mode_name)) do
      maps[map.lhs] = map.desc
    end
    return maps
  end

  if not vim.wait(10000, function()
    return buffer_maps('n')[leader .. 'gs'] ~= nil
  end, 100) then
    record('FAIL', 'gitsigns attached', 'no <leader>gs buffer map after 10s')
    return
  end
  record('PASS', 'gitsigns attached')

  for mode_name, maps in pairs(expected) do
    local actual = buffer_maps(mode_name)
    for lhs, desc in pairs(maps) do
      if actual[lhs] == desc then
        record('PASS', ('buffer keymap %s %s'):format(mode_name, lhs), desc)
      else
        record('FAIL', ('buffer keymap %s %s'):format(mode_name, lhs), ('expected %s, got %s'):format(desc, tostring(actual[lhs])))
      end
    end
  end

  local stale = {}
  for _, map in ipairs(vim.api.nvim_buf_get_keymap(0, 'n')) do
    if map.lhs:sub(1, #leader + 1) == leader .. 'h' then
      stale[#stale + 1] = map.lhs
    end
  end
  if #stale == 0 then
    record('PASS', 'no <leader>h buffer maps')
  else
    record('FAIL', 'no <leader>h buffer maps', join(stale))
  end

  -- Distinct actions must not share a callback: stage and undo-stage are easy to
  -- wire to the same handler by accident.
  local function callback(lhs)
    return vim.fn.maparg(lhs, 'n', false, true).callback
  end
  local pairs_to_check = { { 'gs', 'gu' }, { 'gs', 'gS' }, { 'gd', 'gD' }, { 'gp', 'gb' } }
  for _, pair in ipairs(pairs_to_check) do
    local a, b = callback(leader .. pair[1]), callback(leader .. pair[2])
    local name = ('distinct callbacks <leader>%s <leader>%s'):format(pair[1], pair[2])
    if type(a) == 'function' and type(b) == 'function' and a ~= b then
      record('PASS', name)
    else
      record('FAIL', name, 'shared or missing callback')
    end
  end
end

local handlers = {
  filetype = check_filetype,
  gitsigns = check_gitmaps,
  health = check_health,
  startup = check_startup,
  neotree = check_neotree,
  lazygit = check_lazygit,
}

check_harness()

local handler = handlers[mode]
if not handler then
  record('FAIL', 'harness', 'unknown SMOKE_MODE: ' .. tostring(mode))
else
  local ok, err = pcall(handler)
  if not ok then
    record('FAIL', mode, tostring(err))
  end
end

local failed = false
for _, result in ipairs(results) do
  local line = result.status .. ' ' .. result.name
  if result.detail then
    line = line .. ' (' .. result.detail .. ')'
  end
  io.stdout:write(line .. '\n')
  if result.status == 'FAIL' then
    failed = true
  end
end
io.stdout:flush()

if failed then
  vim.cmd 'cq 1'
else
  vim.cmd 'qa!'
end
