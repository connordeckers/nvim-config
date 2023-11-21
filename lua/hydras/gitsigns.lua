local gitsigns = require 'gitsigns'

local hint = [[
 _J_: Next hunk   	   	
 _K_: Prev hunk   	 		
 _p_: Preview hunk 	   	
 ^
 _s_: Stage Hunk
 _u_: Undo Last Stage	
 _S_: Stage Buffer
 ^
 _d_: Show Deleted
 _r_: Reset hunk	
 _R_: Reset buffer
 ^
 _b_: Line blame
 _B_: Full blame
 _/_: Show Base File
 ^
 _<Enter>_: Commit
 _q_: Exit
]]

return {
  name = 'Git',
  hint = hint,
  config = {
    color = 'pink',
    invoke_on_body = true,
    hint = {
      border = 'rounded',
      position = 'middle-right',
    },
    on_enter = function()
      vim.cmd 'mkview'
      vim.cmd 'silent! %foldopen!'
      -- vim.bo.modifiable = false
      gitsigns.toggle_signs(true)
      gitsigns.toggle_linehl(true)
    end,
    on_exit = function()
      local cursor_pos = vim.api.nvim_win_get_cursor(0)
      vim.cmd 'loadview'
      vim.api.nvim_win_set_cursor(0, cursor_pos)
      vim.cmd 'normal zv'
      gitsigns.toggle_signs(false)
      gitsigns.toggle_linehl(false)
      gitsigns.toggle_deleted(false)
    end,
  },
  body = '<A-g>',
  heads = {
    {
      'J',
      function()
        if vim.wo.diff then
          return ']c'
        end
        vim.schedule(function()
          gitsigns.next_hunk()
        end)
        return '<Ignore>'
      end,
      { expr = true, desc = 'Next Hunk' },
    },
    {
      'K',
      function()
        if vim.wo.diff then
          return '[c'
        end
        vim.schedule(function()
          gitsigns.prev_hunk()
        end)
        return '<Ignore>'
      end,
      { expr = true, desc = 'Prev Hunk' },
    },
    { 's', ':Gitsigns stage_hunk<CR>', { silent = true, desc = 'Stage Hunk' } },
    { 'u', gitsigns.undo_stage_hunk, { desc = 'Undo Last Stage' } },
    { 'S', gitsigns.stage_buffer, { desc = 'Stage Buffer' } },
    { 'p', gitsigns.preview_hunk, { desc = 'Preview Hunk' } },
    { 'd', gitsigns.toggle_deleted, { nowait = true, desc = 'Toggle Deleted' } },
    { 'b', gitsigns.blame_line, { desc = 'Blame' } },
    { 'r', ':Gitsigns reset_hunk<cr>', { desc = 'Reset hunk' } },
    { 'R', gitsigns.reset_buffer, { desc = 'Reset buffer' } },
    {
      'B',
      function()
        gitsigns.blame_line { full = true }
      end,
      { desc = 'Blame Show Full' },
    },
    { '/', gitsigns.show, { exit = true, desc = 'Show Base File' } }, -- show the base of the file
    { '<Enter>', '<cmd>Git commit<CR>', { exit = true, desc = 'vim-fugative commit' } },
    { 'q', nil, { exit = true, nowait = true, desc = 'Exit' } },
  },
}
