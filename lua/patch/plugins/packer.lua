local packer = require 'packer'
local use = packer.use

packer.reset()
packer.init {
  ensure_dependencies = true, -- Should packer install plugin dependencies?
  preview_updates = true, -- If true, always preview updates before choosing which plugins to update, same as `PackerUpdate --preview`.
  git = {
    default_url_format = 'https://github.com/%s', -- Lua format string used for "aaa/bbb" style plugins
  },
  display = {
    open_fn = function()
      local result, win, buf = require('packer.util').float {
        border = require 'patch.border',
      }
      vim.api.nvim_win_set_option(win, 'winhighlight', 'NormalFloat:Normal')
      return result, win, buf
    end,
    compact = true, -- If true, fold updates results by default
    prompt_border = 'double', -- Border style of prompt popups.
    keybindings = { -- Keybindings for the display window
      quit = 'q',
      toggle_update = 'u', -- only in preview
      continue = 'c', -- only in preview
      toggle_info = '<CR>',
      diff = 'd',
      prompt_revert = 'r',
    },
  },
  profile = {
    enable = true,
    threshold = 1, -- integer in milliseconds, plugins which load faster than this won't be shown in profile output
  },
}

-- Packer can manage itself
use 'wbthomason/packer.nvim'

-- Is using a standard Neovim install, i.e. built from source or using a
-- provided appimage.
use {
  'lewis6991/impatient.nvim',
  config = function()
    require('impatient').enable_profile()
  end,
}
