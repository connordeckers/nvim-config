local packer = require 'packer'
local use = packer.use

-- Telescope and its peripheries
use {
  'nvim-telescope/telescope.nvim',
  requires = {
    'nvim-lua/plenary.nvim',
    'kyazdani42/nvim-web-devicons',
    'nvim-telescope/telescope-symbols.nvim',
    {
      'benfowler/telescope-luasnip.nvim',
      requires = { 'L3MON4D3/LuaSnip' },
      module = 'telescope._extensions.luasnip',
    },
  },

  config = function()
    local telescope = require 'telescope'
    local previewers = require 'telescope.previewers'

    local new_maker = function(filepath, bufnr, opts)
      opts = opts or {}

      filepath = vim.fn.expand(filepath)
      vim.loop.fs_stat(filepath, function(_, stat)
        if not stat then
          return
        end
        if stat.size > 100000 then
          return
        else
          previewers.buffer_previewer_maker(filepath, bufnr, opts)
        end
      end)
    end

    telescope.setup {
      defaults = {
        mappings = {
          i = { ['<C-h>'] = 'which_key' },
        },
        buffer_previewer_maker = new_maker,
      },
      pickers = { find_files = { find_command = { 'fd', '--type', 'f', '--strip-cwd-prefix' } } },
      extensions = {},
    }

    telescope.load_extension 'luasnip'
  end,
}
