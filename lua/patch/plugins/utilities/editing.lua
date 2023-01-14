local packer = require 'packer'
local use = packer.use

-- Surround text with other text. Neat!
use {
  'kylechui/nvim-surround',
  after = 'nvim-treesitter-textobjects',
  config = function()
    require('nvim-surround').setup()
  end,
}

-- Lightspeed navigation!
use {
  'ggandor/lightspeed.nvim',
  requires = { 'tpope/vim-repeat' },
  config = function()
    require('lightspeed').setup {}
  end,
}

-- Better, easier, structural renaming.
use {
  'cshuaimin/ssr.nvim',
  module = 'ssr',
  config = function()
    require('ssr').setup {
      min_width = 50,
      min_height = 5,
      keymaps = {
        close = 'q',
        next_match = 'n',
        prev_match = 'N',
        replace_all = '<leader><cr>',
      },
    }
  end,
}

-- Commenting tool
use {
  'numtostr/comment.nvim',
  requires = { 'JoosepAlviste/nvim-ts-context-commentstring' },
  config = function()
    require('Comment').setup {
      ---Add a space b/w comment and the line
      ---@type boolean|fun():boolean
      padding = true,

      ---Whether the cursor should stay at its position
      ---NOTE: This only affects NORMAL mode mappings and doesn't work with dot-repeat
      ---@type boolean
      sticky = true,

      ---Lines to be ignored while comment/uncomment.
      ---Could be a regex string or a function that returns a regex string.
      ---Example: Use '^$' to ignore empty lines
      ---@type string|fun():string
      ignore = nil,
      -- ignore = '^$',

      ---Create basic (operator-pending) and extended mappings for NORMAL + VISUAL mode
      ---NOTE: If `mappings = false` then the plugin won't create any mappings
      ---@type boolean|table
      mappings = {
        --- TODO: @ConnorDeckers
        --- Map these to native Lua methods instead of passing through Vimscript

        basic = false,
        extra = false,
      },

      -- toggler = {
      --   line = '<leader>ci',
      --   block = '<leader>bi',
      -- },
      --
      -- opleader = {
      --   line = '<leader>c',
      --   block = '<leader>b',
      -- },
      --
      -- extra = {
      --   above = '<leader>cO',
      --   below = '<leader>co',
      --   eol = '<leader>cA',
      -- },

      ---Pre-hook, called before commenting the line
      ---@type fun(ctx:CommentCtx):any|nil
      pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      -- pre_hook = function(ctx)
      -- Only calculate commentstring for tsx filetypes
      --if vim.bo.filetype == 'typescript' or vim.bo.filetype == 'javascript' then
      -- local utils = require 'ts_context_commentstring.utils'
      -- local inter = require 'ts_context_commentstring.internal'
      --[[ local comment_utils = require 'comment.utils' ]]

      -- Determine whether to use linewise or blockwise commentstring
      -- local type = ctx.ctype == comment_utils.ctype.linewise and '__default' or '__multiline'

      -- Determine the location where to calculate commentstring from
      -- local location = nil
      -- if ctx.ctype == comment_utils.ctype.blockwise then
      -- location = utils.get_cursor_location()
      -- elseif ctx.cmotion == comment_utils.cmotion.v or ctx.cmotion == comment_utils.cmotion.V then
      -- location = utils.get_visual_start_location()
      -- end

      -- require 'notify'(vim.inspect {
      -- ctx.ctype,
      -- ctx.cmotion,
      -- location,
      -- ctx.ctype == comment_utils.ctype.blockwise,
      -- ctx.cmotion == comment_utils.cmotion.v,
      -- ctx.cmotion == comment_utils.cmotion.V,
      -- })

      -- return inter.calculate_commentstring { key = type, location = location }
      --end
      -- end,

      ---Post-hook, called after commenting is done
      ---@type fun(ctx: CommentCtx)
      post_hook = nil,
    }
  end,
}
