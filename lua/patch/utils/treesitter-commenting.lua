local function debug(...)
  vim.b.debug_notify = vim.notify(vim.inspect(...), nil, {
    replace = vim.b.debug_notify,
    on_open = function(win)
      local buf = vim.api.nvim_win_get_buf(win)
      vim.api.nvim_buf_set_option(buf, 'filetype', 'lua')
    end,
  })
end

-- TODO Make this work with expressions that can support tree-sitter inherently!

local lookups = {
  lua = [[
		 (function_declaration)
		 (function_definition)
	]],

  typescript = [[ 
		 (function)
		 (arrow_function)
	]],
}

lookups.javascript = lookups.typescript

local function FunctionUnderCursor()
  local ts = vim.treesitter

  local bufnr = vim.api.nvim_win_get_buf(0)
  local lang = vim.api.nvim_buf_get_option(bufnr, 'filetype')

  local lookup = lookups[lang]

  if lookup == nil then
    return nil
  end

  local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))

  local parser = ts.get_parser(bufnr, lang)
  local syntax_tree = parser:parse()[1]
  local root = syntax_tree:root()
  local query = ts.parse_query(lang, '([ ' .. lookup .. '] @func (#offset! @func 0 0 0 0))')

  --
  -- ((variable_declaration) @var (#offset! @var 0 0 0 0))
  --

  local matching = {}

  for _, captures, meta in query:iter_matches(root, bufnr) do
    local row, col, _ = captures[1]:start()
    local range = meta[1].range
    local name = ts.query.get_node_text(captures[1], bufnr)

    local start_row, start_col, end_row, end_col = unpack(range)

    if cursor_row >= start_row and cursor_row <= end_row then
      table.insert(matching, { name, row, col, range })
    end
  end

  return matching[#matching]
end

local M = {
  insert = {
    before = {},
    after = {},
  },
}

local function GetCommentFormat()
  -- Only calculate commentstring for tsx filetypes
  local utils = require 'ts_context_commentstring.utils'
  local inter = require 'ts_context_commentstring.internal'

  -- Determine whether to use linewise or blockwise commentstring
  local type = '__default'

  local bufnr = vim.api.nvim_win_get_buf(0)
  local lang = vim.api.nvim_buf_get_option(bufnr, 'filetype')

  -- Determine the location where to calculate commentstring from
  local location = utils.get_cursor_location()

  if lang == 'typescript' then
    return '/** | */'
  end

  return inter.calculate_commentstring { key = type, location = location }
  --end
end

function M.insert.before.fn(msg)
  local method = FunctionUnderCursor()

  if method == nil then
    print 'No method found under cursor'
    return
  end

  local row = method[2]

  local comment_str = string.format(GetCommentFormat(), msg)
  local cursor_index = comment_str:find '|'

  comment_str = comment_str:gsub('|', '')

  local indent = vim.fn.indent(row + 1)
  local line = string.rep(' ', indent) .. comment_str .. ' '

  -- vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { comment_str, string.rep(' ', col) })
  vim.api.nvim_buf_set_lines(0, row, row, false, { line })
  vim.api.nvim_win_set_cursor(0, { row + 1, indent + (cursor_index - 1 or line:len()) })

  vim.cmd 'startinsert'
end

return M
