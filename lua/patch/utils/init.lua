local reload = require 'plenary.reload'
local api = vim.api

-- Utility functions
--
local util = {}
function util.clear_prompt()
  vim.api.nvim_command 'normal! :'
end

function util.get_user_input_char()
  local c = vim.fn.getchar()
  while type(c) ~= 'number' do
    c = vim.fn.getchar()
  end
  return vim.fn.nr2char(c)
end

-- End utility functions

local M = {}

M.window_picker = {
  enable = true,
  chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
  exclude = {
    filetype = { 'notify', 'packer', 'qf', 'diff', 'fugitive', 'fugitiveblame' },
    buftype = { 'nofile', 'terminal', 'help' },
  },
}

function M.filter(t, rule)
  local out = {}

  for key, value in pairs(t) do
    if rule(value, key, t) then
      table.insert(out, value)
    end
  end

  return out
end

function M.safe_require(library, cb)
  local ok, lib = pcall(require, library)
  if not ok then
    return
  end

  return cb(lib)
end

function M.safe_setup(library, config)
  config = config or {}

  local ok, lib = pcall(require, library)
  if not ok then
    return
  end

  lib.setup(config)
end

---Get user to pick a window. Selectable windows are all windows in the current
---tabpage that aren't NvimTree.
---@return integer|nil -- If a valid window was picked, return its id. If an
---       invalid window was picked / user canceled, return nil. If there are
---       no selectable windows, return -1.
function M.pick_window()
  local tabpage = api.nvim_get_current_tabpage()
  local win_ids = api.nvim_tabpage_list_wins(tabpage)

  local selectable = vim.tbl_filter(function(id)
    local bufid = api.nvim_win_get_buf(id)
    for option, v in pairs(M.window_picker.exclude) do
      local ok, option_value = pcall(api.nvim_buf_get_option, bufid, option)
      if ok and vim.tbl_contains(v, option_value) then
        return false
      end
    end

    local win_config = api.nvim_win_get_config(id)
    return win_config.focusable and not win_config.external
  end, win_ids)

  -- If there are no selectable windows: return. If there's only 1, return it without picking.
  if #selectable == 0 then
    return -1
  end
  if #selectable == 1 then
    return selectable[1]
  end

  local i = 1
  local win_opts = {}
  local win_map = {}
  local laststatus = vim.o.laststatus
  vim.o.laststatus = 2

  local not_selectable = vim.tbl_filter(function(id)
    return not vim.tbl_contains(selectable, id)
  end, win_ids)

  if laststatus == 3 then
    for _, win_id in ipairs(not_selectable) do
      local ok_status, statusline = pcall(api.nvim_win_get_option, win_id, 'statusline')
      local ok_hl, winhl = pcall(api.nvim_win_get_option, win_id, 'winhl')

      win_opts[win_id] = {
        statusline = ok_status and statusline or '',
        winhl = ok_hl and winhl or '',
      }

      -- Clear statusline for windows not selectable
      api.nvim_win_set_option(win_id, 'statusline', ' ')
    end
  end

  -- Setup UI
  for _, id in ipairs(selectable) do
    local char = M.window_picker.chars:sub(i, i)
    local ok_status, statusline = pcall(api.nvim_win_get_option, id, 'statusline')
    local ok_hl, winhl = pcall(api.nvim_win_get_option, id, 'winhl')

    win_opts[id] = {
      statusline = ok_status and statusline or '',
      winhl = ok_hl and winhl or '',
    }
    win_map[char] = id

    api.nvim_win_set_option(id, 'statusline', '%=' .. char .. '%=')
    --api.nvim_win_set_option(id, "winhl", "StatusLine:NvimTreeWindowPicker,StatusLineNC:NvimTreeWindowPicker")

    i = i + 1
    if i > #M.window_picker.chars then
      break
    end
  end

  vim.cmd 'redraw'
  print 'Pick window: '
  local _, resp = pcall(util.get_user_input_char)
  resp = (resp or ''):upper()
  util.clear_prompt()

  -- Restore window options
  for _, id in ipairs(selectable) do
    for opt, value in pairs(win_opts[id]) do
      api.nvim_win_set_option(id, opt, value)
    end
  end

  if laststatus == 3 then
    for _, id in ipairs(not_selectable) do
      for opt, value in pairs(win_opts[id]) do
        api.nvim_win_set_option(id, opt, value)
      end
    end
  end

  vim.o.laststatus = laststatus

  if not vim.tbl_contains(vim.split(M.window_picker.chars, ''), resp) then
    return
  end

  return win_map[resp]
end

function M.reload_config()
  for k, v in pairs(package.loaded) do
    package.loaded[k] = nil
  end

  require 'patch'
  require('packer').compile()
end

return M
