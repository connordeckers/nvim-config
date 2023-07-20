return {
  {
    'anuvyklack/hydra.nvim',
    -- dev = true,
    event = 'VeryLazy',
    config = function()
      local Hydra = require 'hydra'
      Hydra(require 'hydras.gitsigns')
    end,
  },
}
