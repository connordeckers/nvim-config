local M = {}

function M.format_buffer(bufnr)
  local null_ls_exists, null_ls = pcall(require, 'null-ls.generators')
  if not null_ls_exists then
    return true
  end

  local filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr })

  local function filter(client)
    if null_ls.can_run(filetype, 'NULL_LS_FORMATTING') or null_ls.can_run(filetype, 'NULL_LS_RANGE_FORMATTING') then
      return client.name == 'null-ls'
    end
  end

  return vim.lsp.buf.format {
    filter = filter,
    timeout_ms = 10000,
  }
end

return M
