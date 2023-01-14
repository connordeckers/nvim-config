local tb = require 'telescope.builtin'
local theme = require 'telescope.themes'
local patch_telescope = require 'patch.telescope'
local cpp_utils = require 'patch.language-features.c++'
local comment = require 'Comment.api'
local tmux = require 'tmux-navigator.controls'
local tscomment = require 'patch.utils.treesitter-commenting'

local tabline = require 'bufferline.functions'

local leader = ' '

local as_dropdown = theme.get_dropdown {}

vim.g.mapleader = leader
vim.g.maplocalleader = leader

local function yank_comment_paste() end
local function insert_jsdoc_comment()
  if vim.bo.filetype == 'typescript' then
    comment.comment.blockwise.current {
      move_cursor_to = 'between',
      pre_hook = function()
        return '/** %s */'
      end,
    }
  else
    comment.comment.linewise.current()
  end
end

local function insert_from_shell()
  -- Ask for prompt value, run as system call
  local utils = require 'patch.utils.string-utils'
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

--- @type table<string, string | function | KeybindTable | KeybindTable[]>
local normalmaps = {
  -- Clear clutter
  ['<Esc>'] = function()
    vim.cmd.noh() -- clear highlights
    vim.cmd.echo() -- clear short-message
  end,

  -- Toggle file tree
  ['<leader>n'] = function()
    require('nvim-tree').toggle()
  end,

  -- Save the file
  -- Only write the file if it's actually changed.
  ['<leader>w'] = vim.cmd.update,

  -- Toggle line numbers
  ['<leader>l'] = function()
    vim.opt.number = not (vim.opt.number:get())
  end,

  -- Replace the word under the cursor
  ['<Leader><Leader>'] = ':%s/\\<<C-r>=expand("<cword>")<CR>\\>//g<Left><Left>',

  -- Format the file
  ['<Leader>p'] = {
    { mode = 'n', action = require('patch.utils.format').format_buffer },
    {
      mode = 'x',
      action = function()
        vim.lsp.buf.range_formatting {}
      end,
      options = { silent = true, buffer = true },
    },
  },

  -- Quickly fold code
  ['<Leader>fa'] = 'za',

  -- Diagnostics
  ['<Leader>tr'] = function()
    require('trouble').toggle()
  end,

  ['<leader>df'] = function()
    tscomment.insert.before.fn ''
  end,

  ['<leader>cd'] = function()
    local my_name = vim.fn.system('git config user.name'):gsub('%s+', '')
    local date = os.date '%Y%m%d'

    tscomment.insert.before.fn(string.format('TODO @%s %s - ', my_name, date))
  end,

  ['<leader>u'] = vim.cmd.UndotreeToggle,

  -------------------
  -- Pane management
  -------------------

  ['<C-h>'] = tmux.navigate.left, -- Move left
  ['<C-j>'] = tmux.navigate.down, -- Move down
  ['<C-k>'] = tmux.navigate.up, -- Move up
  ['<C-l>'] = tmux.navigate.right, -- Move right

  -- Zoom in on a panel
  ['<C-w>z'] = '<C-w>_<C-w><bar>',

  ['<C-w><C-h>'] = function()
    require('swap-buffers').swap_buffers 'h'
  end,
  ['<C-w><C-j>'] = function()
    require('swap-buffers').swap_buffers 'j'
  end,
  ['<C-w><C-k>'] = function()
    require('swap-buffers').swap_buffers 'k'
  end,
  ['<C-w><C-l>'] = function()
    require('swap-buffers').swap_buffers 'l'
  end,

  -------------------
  -- Tab management
  -------------------

  -- New tab
  ['<C-t>'] = function()
    vim.api.nvim_command 'tabnew'
  end,

  -- Next tab
  ['<Tab>'] = tabline.next,

  -- Previous tab
  ['<S-Tab>'] = tabline.previous,

  -- Close the current buffer
  ['<Leader>q'] = tabline.close.this,

  -----------------------
  -- Telescope mapipings
  -----------------------

  -- Show all telescope builtins
  ['<leader>tb'] = function()
    return tb.builtin()
  end,

  -- Show file finder
  ['<leader>tf'] = function()
    tb.find_files()
  end,
  ['<leader>th'] = function()
    tb.find_files { hidden = true }
  end,

  -- Show grep finder
  ['<leader>tg'] = function()
    tb.live_grep()
  end,

  -- Show document symbols
  ['<leader>ts'] = function()
    tb.symbols()
  end,

  -- Show diagnostics
  ['<leader>td'] = function()
    tb.diagnostics(as_dropdown)
  end,

  -- Show config files
  ['<leader>tp'] = function()
    patch_telescope.project_files(as_dropdown)
  end,

  -- Show config files
  ['<leader>ta'] = function()
    patch_telescope.angular(as_dropdown)
  end,

  ['<leader>tn'] = function()
    require('telescope').extensions.notify.notify(as_dropdown)
  end,

  -- Grep current string under cursor within workspace
  ['<leader>ff'] = function()
    tb.grep_string()
  end,

  ['<leader>tj'] = function()
    tb.jumplist(as_dropdown)
  end,

  -- List registers
  ['"'] = function()
    tb.registers(as_dropdown)
  end,

  -- List open buffers
  ['<C-p>'] = function()
    tb.buffers(as_dropdown)
  end,

  -----------------------
  -- Winshift mappings
  -----------------------

  ['<leader>sw'] = function()
    require('winshift').cmd_winshift()
  end,

  ['<leader>ss'] = function()
    require('winshift').cmd_winshift 'swap'
  end,

  -------------------------------
  -- Language-specific bindings
  -------------------------------

  -- Build current file, and run if successful
  ['<leader>rr'] = cpp_utils.build_and_run,

  -- Build current file, but don't run it
  ['<leader>rb'] = cpp_utils.compile,

  -- Run last compiled file
  ['<leader>rc'] = cpp_utils.run,

  -------------------------------
  --  Misc bindings
  -------------------------------

  -- Show the lua scratchpad
  ['<leader>sb'] = require('patch.plugins.utilities.scratch').toggle,

  -- Insert blank comment in Insert mode
  ['<C-c>'] = { mode = 'i', action = insert_jsdoc_comment, options = { silent = true } },

  -- Yank and paste
  ['<Leader>yp'] = {
    mode = 'v',
    action = yank_comment_paste,
    options = { silent = true },
  },

  -- Insert a value into the buffer from the shell
  ['<C-e>'] = { mode = 'i', action = insert_from_shell },

  -- When pasting over a word, delete the word under the selection into the blackhole buffer
  -- This lets us keep our "primary" paste object in memory
  ['p'] = { mode = 'x', action = '"_dP' },

  -- Open git view
  ['<Leader>g'] = require('neogit').open,

  -------------------------------
  --  Comment management
  -------------------------------
  -- Toggle current line (linewise) using C-i
  ['<leader>ci'] = {
    { mode = 'n', action = comment.toggle.linewise.current },
    {
      mode = 'x',
      action = function()
        local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
        vim.api.nvim_feedkeys(esc, 'nx', false)
        comment.toggle.linewise(vim.fn.visualmode())
      end,
    },
  },

  -- Toggle current line (blockwise) using C-b
  ['<leader>cb'] = {
    { mode = 'n', action = comment.toggle.blockwise.current },
    {
      mode = 'x',
      action = function()
        local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
        vim.api.nvim_feedkeys(esc, 'nx', false)
        comment.toggle.blockwise(vim.fn.visualmode())
      end,
    },
  },

  -- Toggle lines (linewise) with dot-repeat support
  -- Example: <leader>gc3j will comment 4 lines
  ['<leader>gc'] = { mode = 'n', action = comment.call('toggle.linewise', 'g@'), options = { expr = true } },

  -- Toggle lines (blockwise) with dot-repeat support
  -- Example: <leader>gb3j will comment 4 lines
  ['<leader>gb'] = { mode = 'n', action = comment.call('toggle.blockwise', 'g@'), options = { expr = true } },

  -------------------------------
  --  Scroll improvements
  -------------------------------

  ['<C-Up>'] = {
    { mode = '', action = '<C-y>', options = { noremap = true } },
    { mode = 'i', action = '<C-O><C-y>', options = { noremap = true } },
  },

  ['<C-Down>'] = {
    { mode = '', action = '<C-e>', options = { noremap = true } },
    { mode = 'i', action = '<C-O><C-e>', options = { noremap = true } },
  },

  -- When scrolling with half-page navigation, keep it fixed in the middle of the screen
  ['<C-u>'] = { mode = 'n', action = '<C-u>zz' },
  ['<C-d>'] = { mode = 'n', action = '<C-d>zz' },

  -- Keep searches in the middle of the screen
  ['n'] = { mode = 'n', action = 'nzzzv' },
  ['N'] = { mode = 'n', action = 'Nzzzv' },

  -------------------------------
  --  Movement improvements
  -------------------------------

  -- Shift-H and Shift-L jump to beginning and end of line, respectively
  ['H'] = { mode = { 'n', 'v' }, action = '^', options = { silent = true, remap = true } },
  ['L'] = { mode = { 'n', 'v' }, action = '$', options = { silent = true, remap = true } },

  ['J'] = {
    { mode = 'n', action = 'mzJ`z' }, -- Join lines without moving cursor
    { mode = 'v', action = ":m '>+1<CR>gv=gv" }, -- Move lines up and down in visual mode
  },
  ['K'] = { mode = { 'v' }, action = ":m '<-2<CR>gv=gv" },
}

local M = {}
function M.reload_keybinds()
  local function is_array(tbl)
    return type(tbl) == 'table' and (#tbl > 0 or next(tbl) == nil)
  end

  local default_opts = { noremap = true, silent = true }

  --- @param prop string | function | KeybindTable | KeybindTable[]
  local function get_values(prop)
    --- @type { mode: string[], action: function | string, options: KeybindOptions }[]
    local responses = {}

    if type(prop) == 'string' or type(prop) == 'function' then
      table.insert(responses, { mode = { 'n' }, action = prop, options = default_opts })
    end

    if type(prop) == 'table' then
      if is_array(prop) then
        for _, p in pairs(prop) do
          local mode = is_array(p.mode) and p.mode or { p.mode }
          local options = vim.tbl_deep_extend('force', default_opts, p.options or {})
          table.insert(responses, { mode = mode, action = p.action, options = options })
        end
      else
        local mode = is_array(prop.mode) and prop.mode or { prop.mode }
        local options = vim.tbl_deep_extend('force', default_opts, prop.options or {})
        table.insert(responses, { mode = mode, action = prop.action, options = options })
      end
    end

    return responses
  end

  for map, props in pairs(normalmaps) do
    for _, param in pairs(get_values(props)) do
      for _, mode in pairs(param.mode) do
        vim.keymap.set(mode, map, param.action, param.options)
      end
    end
  end
end

M.reload_keybinds()

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

return M
