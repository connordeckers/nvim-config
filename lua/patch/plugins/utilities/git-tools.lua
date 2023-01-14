local packer = require 'packer'
local use = packer.use

-- use 'tpope/vim-fugitive'

use {
  'lewis6991/gitsigns.nvim',
  config = function()
    require('gitsigns').setup {
      signcolumn = false,
      numhl = true,
      linehl = false,
      word_diff = false,
      keymaps = {},
      watch_gitdir = { interval = 1000, follow_files = true },
      attach_to_untracked = true,
      current_line_blame = true,
      current_line_blame_opts = { virt_text = true, virt_text_pos = 'eol', delay = 1000 },
      current_line_blame_formatter_opts = { relative_time = false },
      sign_priority = 6,
      update_debounce = 150,
      status_formatter = nil,
      max_file_length = 40000,
      preview_config = {
        border = 'single',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1,
      },
    }
  end,
}

use {
  'TimUntersberger/neogit',
  requires = {
    -- A prettier diff-view
    { 'sindrets/diffview.nvim', requires = { 'nvim-lua/plenary.nvim', 'kyazdani42/nvim-web-devicons' } },
  },
  config = function()
    require('neogit').setup {
      disable_signs = false,
      disable_hint = false,
      disable_context_highlighting = false,
      disable_commit_confirmation = false,

      -- Neogit refreshes its internal state after specific events, which can be expensive depending on the repository size.
      -- Disabling `auto_refresh` will make it so you have to manually refresh the status after you open it.
      auto_refresh = true,
      disable_builtin_notifications = false,
      use_magit_keybindings = false,

      -- Change the default way of opening neogit
      kind = 'vsplit',

      -- Change the default way of opening the commit popup
      commit_popup = { kind = 'split' },

      -- Change the default way of opening popups
      popup = { kind = 'split' },

      -- customize displayed signs
      signs = {
        -- { CLOSED, OPENED }
        section = { '>', 'v' },
        item = { '>', 'v' },
        hunk = { '', '' },
      },

      integrations = {
        -- Neogit only provides inline diffs. If you want a more traditional way to look at diffs, you can use `sindrets/diffview.nvim`.
        -- The diffview integration enables the diff popup, which is a wrapper around `sindrets/diffview.nvim`.
        diffview = true,
      },

      -- Setting any section to `false` will make the section not render at all
      sections = {
        untracked = { folded = false },
        unstaged = { folded = false },
        staged = { folded = false },
        stashes = { folded = true },
        unpulled = { folded = true },
        unmerged = { folded = false },
        recent = { folded = true },
      },
    }
  end,
}
