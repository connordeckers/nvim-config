local highlights = {
  -- Create an "unused" highlight style
  DiagnosticUnnecessary = { italic = true, bold = true, strikethrough = true, underline = false, fg = '#5c6370' },

  -- Provide a background colour for the notification backgrounds.
  NotifyBackground = { bg = '#FFFFFF' },

  -- Dims background when using leap
  LeapBackdrop = { link = 'Comment' },

  -- For light themes, set to 'black' or similar.
  LeapMatch = { fg = 'white', bold = true, nocombine = true },

  -- Of course, specify some nicer shades instead of the default "red" and "blue".
  LeapLabelPrimary = { fg = '#babbf1', bold = true, nocombine = true },
  LeapLabelSecondary = { fg = '#babbf1', italic = true, nocombine = true },

  FloatBorder = { link = 'Float' },
  FloatTitle = { link = 'FloatBorder' },
  NormalFloat = { link = 'Normal' },

  FloatShadow = { link = 'NormalFloat' },
  FloatShadowThrough = { link = 'NormalFloat' },

  NavicSeparator = { link = 'Normal' },
  BarbecueSeparator = { link = 'Normal' },

  LspInlayHint = { fg = '#626880', italic = true },
  LspVirtualText = { link = 'LspInlayHint' },
  GitSignsCurrentLineBlame = { link = 'LspVirtualText' },
}

local create_highlights = function()
  for key, params in pairs(highlights) do
    vim.api.nvim_set_hl(0, key, params)
  end
end

local augroup = vim.api.nvim_create_augroup('patch/hl_augrp', {})
vim.api.nvim_create_autocmd('ColorScheme', { group = augroup, callback = create_highlights })

create_highlights()
