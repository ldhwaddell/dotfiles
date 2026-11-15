require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
  },
  on_attach = function(bufnr)
    local gitsigns = require 'gitsigns'

    local function nav(key, hunk)
      return function()
        if vim.wo.diff then
          vim.cmd.normal { key, bang = true }
        else
          gitsigns.nav_hunk(hunk)
        end
      end
    end

    local function visual(action)
      return function()
        action { vim.fn.line '.', vim.fn.line 'v' }
      end
    end

    local function diff_last()
      gitsigns.diffthis '@'
    end

    local maps = {
      { 'n', ']c', nav(']c', 'next'), 'Jump to next git [c]hange' },
      { 'n', '[c', nav('[c', 'prev'), 'Jump to previous git [c]hange' },
      { 'v', '<leader>gs', visual(gitsigns.stage_hunk), 'Git [s]tage hunk' },
      { 'v', '<leader>gr', visual(gitsigns.reset_hunk), 'Git [r]eset hunk' },
      { 'n', '<leader>gs', gitsigns.stage_hunk, 'Git [s]tage hunk' },
      { 'n', '<leader>gr', gitsigns.reset_hunk, 'Git [r]eset hunk' },
      { 'n', '<leader>gS', gitsigns.stage_buffer, 'Git [S]tage buffer' },
      { 'n', '<leader>gu', gitsigns.undo_stage_hunk, 'Git [u]ndo stage hunk' },
      { 'n', '<leader>gR', gitsigns.reset_buffer, 'Git [R]eset buffer' },
      { 'n', '<leader>gp', gitsigns.preview_hunk, 'Git [p]review hunk' },
      { 'n', '<leader>gb', gitsigns.blame_line, 'Git [b]lame line' },
      { 'n', '<leader>gd', gitsigns.diffthis, 'Git [d]iff against index' },
      { 'n', '<leader>gD', diff_last, 'Git [D]iff against last commit' },
      { 'n', '<leader>tb', gitsigns.toggle_current_line_blame, '[T]oggle git show [b]lame line' },
      { 'n', '<leader>tD', gitsigns.preview_hunk_inline, '[T]oggle git show [D]eleted' },
    }
    for _, m in ipairs(maps) do
      vim.keymap.set(m[1], m[2], m[3], { buffer = bufnr, desc = m[4] })
    end
  end,
}
