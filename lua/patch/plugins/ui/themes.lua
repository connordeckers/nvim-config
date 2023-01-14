local packer = require 'packer'
local use = packer.use

-- Themes
use {
  'rose-pine/neovim',
  as = 'rose-pine',
  -- disable = true,
  config = function()
    require('rose-pine').setup {
      --- @usage 'main' | 'moon'
      dark_variant = 'moon',
      disable_background = true,
      disable_float_background = true,

      --- @usage string hex value or named color from rosepinetheme.com/palette
      groups = {
        background = 'base',
        panel = 'surface',
        border = 'subtle',
        comment = 'muted',
        link = 'iris',
        punctuation = 'subtle',

        float = 'subtle',

        error = 'love',
        hint = 'iris',
        info = 'foam',
        warn = 'gold',

        -- headings = {
        --   h1 = 'iris',
        --   h2 = 'foam',
        --   h3 = 'rose',
        --   h4 = 'gold',
        --   h5 = 'pine',
        --   h6 = 'foam',
        -- },
        -- or set all headings at once
        headings = 'subtle',
      },

      -- Change specific vim highlight groups
      highlight_groups = {
        ColorColumn = { bg = 'rose' },
        Float = { fg = 'subtle' },
      },
    }

    -- set colorscheme after options
    vim.cmd 'colorscheme rose-pine'
  end,
}
