local M = {}
local buf, win
local flag = false

local eval = function()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  load(table.concat(lines, '\n'))()
end

M.toggle = function()
  if not buf or not vim.api.nvim_buf_is_loaded(buf) then
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'ft', 'lua')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'hide')
    vim.keymap.set('n', '<leader>r', eval, { buffer = buf })
  end

  if flag then
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  else
    win = vim.api.nvim_open_win(buf, true, {
      relative = 'editor',
      border = 'rounded',
      style = 'minimal',
      row = 0,
      col = math.ceil(vim.o.columns / 2),
      height = math.ceil(vim.o.lines * 0.66),
      width = math.ceil(vim.o.columns / 2),
    })
  end

  flag = not flag
end

return M
