--- @param key string
--- @param prop string | function | KeybindTable | KeybindTable[]
local function map(key, prop)
  local function is_array(tbl)
    return type(tbl) == 'table' and (#tbl > 0 or next(tbl) == nil)
  end

  local default_opts = { noremap = true, silent = true }

  --- @type { mode: string[], action: function | string, options: KeybindOptions }[]
  local normalised_mappings = {}

  if type(prop) == 'string' or type(prop) == 'function' then
    table.insert(normalised_mappings, { mode = { 'n' }, action = prop, options = default_opts })
  end

  if type(prop) == 'table' then
    if is_array(prop) then
      for _, p in pairs(prop) do
        local mode = is_array(p.mode) and p.mode or { p.mode }
        local options = vim.tbl_deep_extend('force', default_opts, p.options or {})
        table.insert(normalised_mappings, { mode = mode, action = p.action, options = options })
      end
    else
      local mode = is_array(prop.mode) and prop.mode or { prop.mode }
      local options = vim.tbl_deep_extend('force', default_opts, prop.options or {})
      table.insert(normalised_mappings, { mode = mode, action = prop.action, options = options })
    end
  end

  for _, param in pairs(normalised_mappings) do
    for _, mode in pairs(param.mode) do
      vim.keymap.set(mode, key, param.action, param.options)
    end
  end
end

local function run_system_call()
  -- Ask for prompt value, run as system call
  local utils = require 'utils.string-utils'
  local insertCursorAfter = true

  local bufnr = vim.api.nvim_get_current_buf()
  local pos = vim.api.nvim_win_get_cursor(0)

  local row = pos[1] - 1
  local col = pos[2]

  vim.ui.input({ prompt = 'System command', completion = 'shellcmd' }, function(result)
    if result == nil then
      return
    end

    local lines = utils.split(vim.fn.trim(vim.fn.system(result)), '\n')
    vim.api.nvim_buf_set_text(bufnr, row, col, row, col, lines)

    if insertCursorAfter then
      vim.api.nvim_win_set_cursor(0, { row + #lines, col + string.len(lines[#lines]) })
    else
      vim.api.nvim_win_set_cursor(0, { row + 1, col })
    end
  end)
end

-- Clear clutter
map('<Esc>', function()
  vim.cmd.noh() -- clear highlights
  vim.cmd.echo() -- clear short-message

  local has_notify, notify_lib = pcall(require, 'notify')
  if has_notify then
    notify_lib.dismiss { pending = true, silent = true }
  end
end)

map('<Leader><Esc>', { action = '<C-\\><C-n>', mode = 't' })

-- Save the file
-- Only write the file if it's actually changed.
map('<leader>w', vim.cmd.update)

-- Toggle line numbers
map('<leader>ln', function()
  vim.opt.number = not (vim.opt.number:get())
end)

-- Replace the word under the cursor
-- map('<Leader><Leader>', ':%s/\\<<C-r>=expand("<cword>")<CR>\\>//g<Left><Left>')

-- Format the file
-- map('<Leader>p', {
--   {
--     mode = 'n',
--     action = function()
--       require('utils.format').format_buffer()
--     end,
--   },
--   {
--     mode = 'x',
--     action = function()
--       vim.lsp.buf.range_formatting {}
--     end,
--     options = { silent = true, buffer = true },
--   },
-- })

-- Quickly fold code

-- Close all folds
map('<Leader>ffa', 'zM')

-- Open all folds
map('<Leader>fua', 'zR')

-- Fold under cursor
map('(', 'zc')
map(')', 'zo')

-- Zoom in on a panel
map('<C-w>z', '<C-w>_<C-w><bar>')

-- Insert a value into the buffer from the shell
map('<C-e>', { mode = 'i', action = run_system_call })

-------------------------------
--  Scroll improvements
-------------------------------

map('<C-Up>', {
  { mode = 'n', action = '<C-y>', options = { noremap = true } },
  { mode = 'i', action = '<C-O><C-y>', options = { noremap = true } },
})

map('<C-Down>', {
  { mode = 'n', action = '<C-e>', options = { noremap = true } },
  { mode = 'i', action = '<C-O><C-e>', options = { noremap = true } },
})

-- When scrolling with half-page navigation, keep it fixed in the middle of the screen
map('<C-u>', '<C-u>zz')
map('<C-d>', '<C-d>zz')

-- Keep searches in the middle of the screen
map('n', 'nzzzv')
map('N', 'Nzzzv')

-------------------------------
--  Movement improvements
-------------------------------

-- Shift-H and Shift-L jump to beginning and end of line, respectively
map('H', { mode = { 'n', 'v' }, action = '^', options = { silent = true, remap = true } })
map('L', { mode = { 'n', 'v' }, action = '$', options = { silent = true, remap = true } })

map('J', {
  { mode = 'n', action = 'mzJ`z' }, -- Join lines without moving cursor
  { mode = 'v', action = ":m '>+1<CR>gv=gv" }, -- Move lines up and down in visual mode
})

map('K', { mode = { 'v' }, action = ":m '<-2<CR>gv=gv" })

--- @class KeybindOptions
--- @field silent? boolean
--- @field expr? boolean
--- @field replace_keycodes? boolean
--- @field remap? boolean
--- @field noremap? boolean
--- @field buffer? boolean | number
--- @field nowait? boolean | number
--- @field script? boolean | number
--- @field unique? boolean | number

--- @class KeybindTable
--- @field mode string | string[]
--- @field action function | string
--- @field options? KeybindOptions
