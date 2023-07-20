local function lines(str)
  local result = {}
  for line in str:gmatch '[^\n]+' do
    table.insert(result, line)
  end
  return result
end

local function dump(output, bufnr)
  if bufnr ~= 0 and not bufnr then
    vim.api.nvim_command 'new'
    bufnr = vim.api.nvim_get_current_buf()
  end

  vim.api.nvim_buf_set_lines(bufnr, -1, -1, true, lines(vim.inspect(output)))
end

return dump
