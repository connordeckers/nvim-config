local Window = {}

local current_window = vim.api.nvim_get_current_win

local split = {
  below = vim.opt.splitbelow:get(),
  right = vim.opt.splitright:get(),
}

function Window.split_left()
  local original = current_window()
  vim.cmd 'vnew'

  if split.right then
    vim.cmd 'wincmd h'
  end

  local newpane = current_window()

  vim.api.nvim_set_current_win(original)

  return newpane
end

function Window.split_right()
  local original = current_window()
  vim.cmd 'vnew'

  if not split.right then
    vim.cmd 'wincmd l'
  end

  local newpane = current_window()

  vim.api.nvim_set_current_win(original)

  return newpane
end

function Window.split_above()
  local original = current_window()
  vim.cmd 'new'

  if split.below then
    vim.cmd 'wincmd k'
  end

  local newpane = current_window()

  vim.api.nvim_set_current_win(original)

  return newpane
end

function Window.split_below()
  local original = current_window()
  vim.cmd 'new'

  if not split.below then
    vim.cmd 'wincmd j'
  end

  local newpane = current_window()

  vim.api.nvim_set_current_win(original)

  return newpane
end

function Window.new_tab(focused)
  local original_tab = vim.api.nvim_tabpage_get_number(0)

  vim.cmd 'tabnew'
  local new_tab = vim.api.nvim_tabpage_get_number(0)

  if not focused then
    vim.api.nvim_set_current_tabpage(original_tab)
  end

  return new_tab
end

function Window.load_file(winnr, file)
  local original_buffer = vim.api.nvim_get_current_win()

  vim.api.nvim_set_current_win(winnr)
  vim.cmd('edit ' .. vim.fn.expand(file))

  -- vim.api.nvim_set_current_buf(original_buffer)
end

return Window

-- local M = {}
-- function M.split()
--   local project = '~/dev/personal/docki/'
--   local files = {
--     a = project .. "beacon/src/index.ts",
--     b = project .. "package.json",
--     c = project .. "api/src/index.ts"
--   }
--
--   local topleft = current_window()
--   local right = Window.split_right()
--   local bottomleft = Window.split_below()
--
--   Window.load_file(topleft, files.a)
--   Window.load_file(bottomleft, files.b)
--   Window.load_file(right, files.c)
-- end
--
-- M.split()
--
-- return M
