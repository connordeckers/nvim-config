vim.diagnostic.config {
  underline = true,
  virtual_text = false,
  float = {
    show_header = true,
    source = 'if_many',
    border = 'rounded',
    focusable = false,
  },
}

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = require 'patch.border' })
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = require 'patch.border' })

vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false, scope = 'cursor' })
  end,
})
