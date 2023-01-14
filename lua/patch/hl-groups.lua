local highlights = {
  -- Create an "unused" highlight style
  ['UnusedToken'] = { italic = true, bold = true, strikethrough = true, underline = false, fg = '#5c6370' },

  -- Provide a background colour for the notification backgrounds.
  ['NotifyBackground'] = { bg = '#FFFFFF' },

  -- ['Float'] = { link = 'Normal' },
  --
  ['FloatBorder'] = { link = 'Float' },
  ['FloatTitle'] = { link = 'FloatBorder' },
  ['NormalFloat'] = { link = 'Normal' },

  ['FloatShadow'] = { link = 'NormalFloat' },
  ['FloatShadowThrough'] = { link = 'NormalFloat' },

  ['NavicSeparator'] = { link = 'Normal' },
  ['BarbecueSeparator'] = { link = 'Normal' },
}

local create_highlights = function()
  for key, params in pairs(highlights) do
    vim.api.nvim_set_hl(0, key, params)
  end
end

local augroup = vim.api.nvim_create_augroup('patch/hl_augrp', {})
vim.api.nvim_create_autocmd('ColorScheme', { group = augroup, callback = create_highlights })

create_highlights()
