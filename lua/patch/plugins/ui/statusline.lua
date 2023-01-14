local packer = require 'packer'
local use = packer.use

-- Install status line support
use {
  'nvim-lualine/lualine.nvim',
  -- after = 'noice.nvim',
  requires = { 'SmiteshP/nvim-navic', 'kyazdani42/nvim-web-devicons', opt = true },
  config = function()
    -- local noice = require('noice').api.status

    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = 'auto',
        -- theme = 'rose-pine',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = { 'NvimTree' },
        always_divide_middle = true,
        globalstatus = false,
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { { 'filename', path = 1, file_status = true } },
        lualine_x = {
          'filesize',
          'filetype',
        },
        lualine_y = {
          -- { noice.message.get_hl, cond = noice.message.has },
          -- { noice.command.get_hl, cond = noice.command.has },
          -- { noice.mode.get_hl, cond = noice.mode.has },
          -- { noice.search.get_hl, cond = noice.search.has },
        },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = {},
    }

    vim.cmd [[
				set guioptions-=e
				set sessionoptions+=tabpages,globals
		]]
  end,
}

use {
  -- 'romgrk/barbar.nvim',
  'connordeckers/barbar.nvim',
  -- '~/dev/personal/neovim-plugins/barbar.nvim',
  requires = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    -- Set barbar's options
    require('bufferline').setup {
      -- Enable/disable animations
      animation = true,

      -- Enable/disable auto-hiding the tab bar when there is a single buffer
      auto_hide = false,

      -- Enable/disable current/total tabpages indicator (top right corner)
      tabpages = true,

      -- Enable/disable close button
      closable = true,

      -- Enables/disable clickable tabs
      --  - left-click: go to buffer
      --  - middle-click: delete buffer
      clickable = true,

      -- Enables / disables diagnostic symbols
      diagnostics = {
        -- OR `vim.diagnostic.severity`
        [vim.diagnostic.severity.ERROR] = { enabled = true, icon = 'ﬀ' },
        [vim.diagnostic.severity.WARN] = { enabled = false },
        [vim.diagnostic.severity.INFO] = { enabled = false },
        [vim.diagnostic.severity.HINT] = { enabled = false },
      },

      -- Excludes buffers from the tabline
      exclude_ft = {
        'fugitive',
      },
      exclude_name = {},

      -- Hide inactive buffers and file extensions. Other options are `current` and `visible`
      hide = { extensions = true, inactive = false },

      -- Enable/disable icons
      -- if set to 'numbers', will show buffer index in the tabline
      -- if set to 'both', will show buffer index and icons in the tabline
      icons = true,

      -- If set, the icon color will follow its corresponding buffer
      -- highlight group. By default, the Buffer*Icon group is linked to the
      -- Buffer* group (see Highlighting below). Otherwise, it will take its
      -- default value as defined by devicons.
      icon_custom_colors = false,

      -- Configure icons on the bufferline.
      icon_separator_active = '▎',
      icon_separator_inactive = '▎',
      icon_close_tab = '',
      icon_close_tab_modified = '●',
      icon_pinned = '車',

      -- If true, new buffers will be inserted at the start/end of the list.
      -- Default is to insert after current buffer.
      insert_at_end = false,
      insert_at_start = false,

      -- Sets the maximum padding width with which to surround each tab
      maximum_padding = 1,

      -- Sets the minimum padding width with which to surround each tab
      minimum_padding = 1,

      -- Sets the maximum buffer name length.
      maximum_length = 30,

      -- If set, the letters for each buffer in buffer-pick mode will be
      -- assigned based on their name. Otherwise or in case all letters are
      -- already assigned, the behavior is to assign letters in order of
      -- usability (see order below)
      semantic_letters = true,

      -- New buffer letters are assigned in this order. This order is
      -- optimal for the qwerty keyboard layout but might need adjustement
      -- for other layouts.
      letters = 'asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP',

      -- Sets the name of unnamed buffers. By default format is "[Buffer X]"
      -- where X is the buffer number. But only a static string is accepted here.
      no_name_title = nil,

      -- Use Rose Pine if it's installed and available
      -- highlights = has_rose_pine and highlights or nil,
    }
  end,
}

use {
  'utilyre/barbecue.nvim',
  requires = {
    'neovim/nvim-lspconfig',
    'smiteshp/nvim-navic',
    'kyazdani42/nvim-web-devicons', -- optional
  },
  config = function()
    require('barbecue').setup {
      ---whether to attach navic to language servers automatically
      ---@type boolean
      attach_navic = true,

      ---whether to create winbar updater autocmd
      ---@type boolean
      create_autocmd = true,

      ---buftypes to enable winbar in
      ---@type string[]
      include_buftypes = { '' },

      ---filetypes not to enable winbar in
      ---@type string[]
      exclude_filetypes = { 'toggleterm' },

      modifiers = {
        ---filename modifiers applied to dirname
        ---@type string
        dirname = ':~:.',

        ---filename modifiers applied to basename
        ---@type string
        basename = '',
      },

      ---returns a string to be shown at the end of winbar
      ---@type fun(bufnr: number): string
      custom_section = function()
        return ''
      end,

      ---whether to replace file icon with the modified symbol when buffer is modified
      ---@type boolean
      show_modified = false,

      symbols = {
        ---modification indicator
        ---@type string
        modified = '●',

        ---truncation indicator
        ---@type string
        ellipsis = '…',

        ---entry separator
        ---@type string
        separator = '',
      },

      ---icons for different context entry kinds
      ---`false` to disable kind icons
      ---@type table<string, string>|false
      kinds = {
        File = '',
        Package = '',
        Module = '',
        Namespace = '',
        Macro = '',
        Class = '',
        Constructor = '',
        Field = '',
        Property = '',
        Method = '',
        Struct = '',
        Event = '',
        Interface = '',
        Enum = '',
        EnumMember = '',
        Constant = '',
        Function = '',
        TypeParameter = '',
        Variable = '',
        Operator = '',
        Null = '',
        Boolean = '',
        Number = '',
        String = '',
        Key = '',
        Array = '',
        Object = '',
      },
    }
  end,
}
