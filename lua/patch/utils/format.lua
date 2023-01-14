local M = {}

local function filter(client)
  return client.name == 'null-ls'
  --return client.name ~= "html"
end

function M.format_buffer(bufnr)
  local args = { filter = filter, timeout_ms = 10000 }
  -- if bufnr ~= nil then args.bufnr = bufnr end
  return vim.lsp.buf.format(args)
  --return vim.lsp.buf.formatting(args)
end

return M
