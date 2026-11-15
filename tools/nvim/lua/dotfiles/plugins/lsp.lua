local attach_group = vim.api.nvim_create_augroup('dotfiles-lsp-attach', { clear = true })

vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })

vim.api.nvim_create_autocmd('LspAttach', {
  group = attach_group,
  callback = function(event)
    local map = function(keys, action, desc)
      vim.keymap.set('n', keys, action, { buffer = event.buf, desc = desc })
    end

    map('grr', function()
      require('fzf-lua').lsp_references()
    end, '[G]oto [R]eferences')
    map('gri', function()
      require('fzf-lua').lsp_implementations()
    end, '[G]oto [I]mplementation')
    map('grd', function()
      require('fzf-lua').lsp_definitions()
    end, '[G]oto [D]efinition')
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    map('gO', function()
      require('fzf-lua').lsp_document_symbols()
    end, 'Document symbols')
    map('gW', function()
      require('fzf-lua').lsp_live_workspace_symbols()
    end, 'Workspace symbols')
    map('grt', function()
      require('fzf-lua').lsp_typedefs()
    end, '[G]oto [T]ype definition')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }, { bufnr = event.buf })
      end, '[T]oggle inlay [H]ints')
    end
  end,
})

-- Check support at request time: clients can detach or change capabilities.
vim.api.nvim_create_autocmd('CursorHold', {
  callback = function(event)
    if #vim.lsp.get_clients { bufnr = event.buf, method = 'textDocument/documentHighlight' } > 0 then
      vim.lsp.buf.document_highlight()
    end
  end,
  desc = 'Highlight document references',
})
vim.api.nvim_create_autocmd('CursorMoved', {
  callback = vim.lsp.buf.clear_references,
  desc = 'Clear document references',
})

-- lua_ls needs the Neovim runtime and runtimepath to resolve `vim.*` and plugin
-- modules; a project's own .luarc.json wins (early return above).
vim.lsp.config('lua_ls', {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua or {}, {
      runtime = {
        version = 'LuaJIT',
        path = { 'lua/?.lua', 'lua/?/init.lua' },
      },
      workspace = {
        checkThirdParty = false,
        library = vim.list_extend(vim.api.nvim_get_runtime_file('', true), {
          '${3rd}/luv/library',
          '${3rd}/busted/library',
        }),
      },
    })
  end,
  settings = { Lua = {} },
})

vim.lsp.enable { 'tsc', 'ruff', 'ty', 'stylua', 'oxlint', 'rust_analyzer', 'lua_ls' }

-- One message id for all LSP progress: ui2 gives each id its own cmdline row,
-- so per-token ids stack when several servers (or tokens) report at once.
vim.api.nvim_create_autocmd('LspProgress', {
  group = vim.api.nvim_create_augroup('dotfiles-lsp-progress', { clear = true }),
  callback = function(ev)
    local value = ev.data.params.value
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local title = (client and client.name or 'lsp') .. (value.title and (': ' .. value.title) or '')
    local text = (value.message or 'done'):sub(1, math.max(10, vim.o.columns - #title - 10))
    vim.api.nvim_echo({ { text } }, false, {
      id = 'lsp.progress',
      kind = 'progress',
      source = 'vim.lsp',
      title = title,
      status = value.kind ~= 'end' and 'running' or 'success',
      percent = value.percentage,
    })
  end,
})
