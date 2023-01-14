local packer = require 'packer'
local use = packer.use

use {
  'Kasama/nvim-custom-diagnostic-highlight',
  config = function()
    local highlight = require 'nvim-custom-diagnostic-highlight'
    local hlgrp = require 'patch.hl-groups'

    highlight.setup {
      -- Whether to register the handler automatically
      register_handler = true,

      -- The name of the handler to be registered (has no effect if register_handler = false)
      handler_name = 'patch/diagnostics-hl',

      -- The Highlight group to set at the diagnostic
      highlight_group = 'UnusedToken',

      -- Extra lua patterns to add. Does NOT override and will be added to the above
      extra_patterns = {},

      -- Name of the handler namespace that will contain the highlight (needs to be unique)
      diagnostic_handler_namespace = hlgrp,
    }
  end,
}

-- Diagnostics that are pretty
use {
  'folke/trouble.nvim',
  module = 'trouble',
  requires = 'kyazdani42/nvim-web-devicons',
  config = function()
    require('trouble').setup {
      position = 'right', -- position of the list can be: bottom, top, left, right
      height = 10, -- height of the trouble list when position is top or bottom
      width = 50, -- width of the list when position is left or right
      icons = true, -- use devicons for filenames
      mode = 'document_diagnostics', -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
      fold_open = '', -- icon used for open folds
      fold_closed = '', -- icon used for closed folds
      group = true, -- group results by file
      padding = true, -- add an extra new line on top of the list
      indent_lines = true, -- add an indent guide below the fold icons
      auto_open = false, -- automatically open the list when you have diagnostics
      auto_close = false, -- automatically close the list when you have no diagnostics
      auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
      auto_fold = false, -- automatically fold a file trouble list at creation
    }
  end,
}

-- Debug Adaptor Protocol
use { 'mfussenegger/nvim-dap', opt = true }
