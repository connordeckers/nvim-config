local lsp_util = require 'vim.lsp.util'
local utils = require 'patch.utils.lsp-utils.utils'

-- local function debug(...)
--   vim.b.debug_notify = vim.notify(vim.inspect(...), nil, {
--     replace = vim.b.debug_notify,
--     on_open = function(win)
--       local buf = vim.api.nvim_win_get_buf(win)
--       vim.api.nvim_buf_set_option(buf, 'filetype', 'lua')
--     end,
--   })
-- end

-- the symbol kinds which are valid scopes
local scope_kinds = {
  Class = true,
  Function = true,
  Method = true,
  Struct = true,
  Enum = true,
  Interface = true,
  Namespace = true,
  Module = true,
  Variable = true,
}

local function symbols()
  local _symbols = vim.lsp.buf_request_sync(0, 'textDocument/documentSymbol', { textDocument = lsp_util.make_text_document_params() })
  for _, response in pairs(_symbols) do
    local result = response.result

    -- Find current function context
    if type(result) ~= 'table' then
      do
        break
      end
    end

    local function_symbols = utils.filter(utils.extract_symbols(result), function(_, v)
      return scope_kinds[v.kind]
    end)

    if not function_symbols or #function_symbols == 0 then
      do
        break
      end
    end

    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    local matching_symbols = utils.filter(function_symbols, function(_, sym)
      return sym.range and utils.in_range(cursor_pos, sym.range)
    end)

    if #matching_symbols > 0 then
      return matching_symbols
    end
  end
end

return {
  get_symbols = symbols,
}
