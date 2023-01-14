local packer = require 'packer'
local use = packer.use

---------------------------
--    Task management
---------------------------

use {
  'anuvyklack/hydra.nvim',
  disable = true,
  requires = {
    -- For Git hydra
    'lewis6991/gitsigns.nvim',
    'TimUntersberger/neogit',

    -- For window management
    'romgrk/barbar.nvim',
    'jlanzarotta/bufexplorer',
    'sindrets/winshift.nvim',
    'mrjones2014/smart-splits.nvim',
    'anuvyklack/windows.nvim',
  },
  config = function()
    require 'patch.plugins.utilities.hydras.window-mgmt'
    require 'patch.plugins.utilities.hydras.git'
  end,
}
