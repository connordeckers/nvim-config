local default_bg = '#000000'

---@param hex_str string hexadecimal value of a color
local function hex_to_rgb(hex_str)
  local hex = '[abcdef0-9][abcdef0-9]'
  local pat = '^#(' .. hex .. ')(' .. hex .. ')(' .. hex .. ')$'
  hex_str = string.lower(hex_str)

  assert(string.find(hex_str, pat) ~= nil, 'hex_to_rgb: invalid hex_str: ' .. tostring(hex_str))

  local red, green, blue = string.match(hex_str, pat)
  return { tonumber(red, 16), tonumber(green, 16), tonumber(blue, 16) }
end

---@param fg string forecrust color
---@param bg string background color
---@param alpha number number between 0 and 1. 0 results in bg, 1 results in fg
local function blend(fg, bg, alpha)
  local bg_rgb = hex_to_rgb(bg)
  local fg_rgb = hex_to_rgb(fg)

  local blendChannel = function(i)
    local ret = (alpha * fg_rgb[i] + ((1 - alpha) * bg_rgb[i]))
    return math.floor(math.min(math.max(0, ret), 255) + 0.5)
  end

  return string.format('#%02X%02X%02X', blendChannel(1), blendChannel(2), blendChannel(3))
end

return {
  -- Catppuccin theme
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    init = function()
      vim.cmd.colorscheme 'catppuccin'
    end,
    opts = {
      flavour = 'frappe', -- latte, frappe, macchiato, mocha
      background = {
        -- :h background
        light = 'latte',
        dark = 'mocha',
      },
      transparent_background = false,
      show_end_of_buffer = false, -- show the '~' characters after the end of buffers
      term_colors = false,
      dim_inactive = { enabled = false },
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        telescope = true,
        notify = true,
        mini = true,
        barbar = true,
        -- indent_blankline = {
        --   enabled = true,
        --   colored_indent_levels = true,
        -- },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { 'italic' },
            hints = { 'italic' },
            warnings = { 'italic' },
            information = { 'italic' },
          },
          underlines = {
            errors = { 'underline' },
            hints = { 'underline' },
            warnings = { 'underline' },
            information = { 'underline' },
          },
        },
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
      },

      custom_highlights = function(palette)
        local function subtle(color)
          return blend(color, default_bg, 0.5)
        end

        return {
          IndentBlanklineChar = { fg = palette.surface0 },
          IndentBlanklineContextChar = { fg = palette.text },
          IndentBlanklineContextStart = { sp = palette.text, style = { 'underline' } },

          IndentBlanklineIndent6 = { blend = 0, fg = subtle(palette.yellow) },
          IndentBlanklineIndent5 = { blend = 0, fg = subtle(palette.red) },
          IndentBlanklineIndent4 = { blend = 0, fg = subtle(palette.teal) },
          IndentBlanklineIndent3 = { blend = 0, fg = subtle(palette.peach) },
          IndentBlanklineIndent2 = { blend = 0, fg = subtle(palette.blue) },
          IndentBlanklineIndent1 = { blend = 0, fg = subtle(palette.pink) },
        }
      end,
    },
  },

  {
    'lukas-reineke/headlines.nvim',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    opts = {
      markdown = {
        fat_headlines = true,
        fat_headline_upper_string = '▅',
        fat_headline_lower_string = '▀',
      },
    },
    event = 'BufRead',
  },

  -- Make it easier to use search functionality
  { 'junegunn/vim-slash', event = 'BufRead' },

  -- Make things PRETTY
  {
    'stevearc/dressing.nvim',
    event = 'VeryLazy',
    opts = {
      input = {
        -- Can be 'left', 'right', or 'center'
        prompt_align = 'center',

        -- These are passed to nvim_open_win
        anchor = 'NW',
        border = 'rounded',

        -- 'editor' and 'win' will default to being centered
        relative = 'cursor',

        win_options = {
          -- Window transparency (0-100)
          -- This fixes the black background in float windows
          winblend = 0,
        },
      },

      select = {
        -- Options for nui Menu
        nui = { border = { style = 'rounded' } },

        -- Options for built-in selector
        builtin = { border = 'rounded' },

        -- Priority list of preferred vim.select implementations
        backend = { 'telescope', 'fzf_lua', 'fzf', 'builtin', 'nui' },

        get_config = function(opts)
          local has_telescope, themes = pcall(require, 'telescope.themes')
          if has_telescope and opts.kind == 'codeaction' then
            return {
              backend = 'telescope',
              telescope = themes.get_cursor { initial_mode = 'normal' },
            }
          end
        end,
      },
    },
  },

  -- local banned_messages = { 'No information available', 'multiple different client offset_encodings' }
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      'rcarriga/nvim-notify',
    },

    opts = {
      cmdline = {
        enabled = true, -- enables the Noice cmdline UI

        --- @type table<string, CmdlineFormat>
        format = {
          lua = { pattern = '^:%s*lua=?%s+', icon = '', lang = 'lua' },
          input = {},
        },
      },

      -- You can add any custom commands below that will be available with `:Noice command`
      ---@type table<string, NoiceCommand>
      commands = {},

      lsp = {
        progress = {
          format_done = {
            { ' ', hl_group = 'NoiceLspProgressSpinner' },
            { '{data.progress.title} ', hl_group = 'NoiceLspProgressTitle' },
            { '{data.progress.client} ', hl_group = 'NoiceLspProgressClient' },
          },
        },
        override = {
          -- override the default lsp markdown formatter with Noice
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          -- override the lsp markdown formatter with Noice
          ['vim.lsp.util.stylize_markdown'] = true,
          -- override cmp documentation with Noice (needs the other options to work)
          ['cmp.entry.get_documentation'] = false,
        },

        hover = {
          enabled = true,
          opts = { border = 'rounded' },
        },

        signature = {
          enabled = true,
          opts = { border = 'rounded' },
        },
      },

      ---@type NoicePresets
      presets = {
        -- you can enable a preset by setting it to true, or a table that will override the preset config
        -- you can also add custom presets that you can enable/disable with enabled=true
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = true, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },

      ---@type NoiceConfigViews
      views = {
        virtualtext = { hl_group = 'LspVirtualText' },
        mini = {
          win_options = {
            winblend = 0, -- Make background transparent for nice acrylic finish
          },
        },
      }, ---@see section on views

      ---@type NoiceRouteConfig[]
      routes = {
        {
          filter = {
            any = {
              { find = 'search hit' },
              { find = 'Diagnosing' },
              { find = 'Processing full semantic tokens' },
              { find = 'No information available' },
              { find = 'multiple different client offset_encodings' },
              { find = 'not indexed' },
              { find = 'Inlay Hints request failed.' },
            },
          },
          opts = { skip = true },
        },

        {
          filter = {
            any = {
              { find = 'Pattern not found' },
              { find = 'cwd:' },
              { find = 'written' },
              { find = 'before #' },
              { find = 'after #' },
            },
          },
          view = 'mini',
        },
      }, --- @see section on routes
    },
  },
  -- Zen mode
  {
    'folke/zen-mode.nvim',
    cmd = { 'ZenMode' },
    keys = {
      {
        '<leader>zz',
        function()
          require('zen-mode').toggle()
        end,
      },
    },
    dependencies = {
      {
        'folke/twilight.nvim',
        opts = {
          dimming = {
            alpha = 0.25, -- amount of dimming
            -- we try to get the foreground from the highlight groups or fallback color
            color = { 'Normal', '#ffffff' },
            term_bg = '#000000', -- if guibg=NONE, this will be used to calculate text color
            inactive = false, -- when true, other windows will be fully dimmed (unless they contain the same buffer)
          },
          context = 10, -- amount of lines we will try to show around the current line
          treesitter = true, -- use treesitter when available for the filetype
        },
      },
    },
    opts = {
      window = {
        backdrop = 0.95, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
        -- height and width can be:
        -- * an absolute number of cells when > 1
        -- * a percentage of the width / height of the editor when <= 1
        -- * a function that returns the width or the height
        width = 0.75, -- width of the Zen window
        height = 1, -- height of the Zen window
        -- by default, no options are changed for the Zen window
        -- uncomment any of the options below, or add other vim.wo options you want to apply
        options = {
          signcolumn = 'no', -- disable signcolumn
          number = false, -- disable number column
          relativenumber = false, -- disable relative numbers
          -- cursorline = false, -- disable cursorline
          -- cursorcolumn = false, -- disable cursor column
          foldcolumn = '0', -- disable fold column
          -- list = false, -- disable whitespace characters
        },
      },
      plugins = {
        -- disable some global vim options (vim.o...)
        -- comment the lines to not apply the options
        options = {
          enabled = true,
          ruler = false, -- disables the ruler text in the cmd line area
          showcmd = false, -- disables the command in the last line of the screen
        },
        twilight = { enabled = true }, -- enable to start Twilight when zen mode opens
        gitsigns = { enabled = false }, -- disables git signs
      },
    },
  },

  -- Scrollbar
  -- {
  --   'petertriho/nvim-scrollbar',
  --   event = { 'BufReadPre', 'BufNewFile' },
  --   opts = {
  --     show = true,
  --     show_in_active_only = false,
  --     set_highlights = true,
  --     folds = false, -- handle folds, set to number to disable folds if no. of lines in buffer exceeds this
  --     max_lines = false, -- disables if no. of lines in buffer exceeds this
  --     handle = {
  --       text = ' ',
  --       color = nil,
  --       cterm = nil,
  --       highlight = 'CursorColumn',
  --       hide_if_all_visible = true, -- Hides handle if all lines are visible
  --     },
  --     marks = {
  --       Search = {
  --         text = { '-', '=' },
  --         priority = 0,
  --         color = nil,
  --         cterm = nil,
  --         highlight = 'Search',
  --       },
  --       Error = {
  --         text = { '-', '=' },
  --         priority = 1,
  --         color = nil,
  --         cterm = nil,
  --         highlight = 'DiagnosticVirtualTextError',
  --       },
  --       Warn = {
  --         text = { '-', '=' },
  --         priority = 2,
  --         color = nil,
  --         cterm = nil,
  --         highlight = 'DiagnosticVirtualTextWarn',
  --       },
  --       Info = {
  --         text = { '-', '=' },
  --         priority = 3,
  --         color = nil,
  --         cterm = nil,
  --         highlight = 'DiagnosticVirtualTextInfo',
  --       },
  --       Hint = {
  --         text = { '-', '=' },
  --         priority = 4,
  --         color = nil,
  --         cterm = nil,
  --         highlight = 'DiagnosticVirtualTextHint',
  --       },
  --       Misc = {
  --         text = { '-', '=' },
  --         priority = 5,
  --         color = nil,
  --         cterm = nil,
  --         highlight = 'Normal',
  --       },
  --     },
  --     excluded_buftypes = {
  --       'terminal',
  --       'NvimTree',
  --     },
  --     excluded_filetypes = {
  --       'prompt',
  --       'TelescopePrompt',
  --     },
  --     autocmd = {
  --       render = {
  --         'BufWinEnter',
  --         'TabEnter',
  --         'TermEnter',
  --         'WinEnter',
  --         'CmdwinLeave',
  --         'TextChanged',
  --         'VimResized',
  --         'WinScrolled',
  --       },
  --       clear = {
  --         'BufWinLeave',
  --         'TabLeave',
  --         'TermLeave',
  --         'WinLeave',
  --       },
  --     },
  --     handlers = {
  --       cursor = true,
  --       gitsigns = true,
  --       diagnostic = true,
  --       search = false, -- Requires hlslens to be loaded, will run require("scrollbar.handlers.search").setup() for you
  --     },
  --   },
  -- },

  -- Status and buffer bar
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VeryLazy',
    opts = {
      options = {
        icons_enabled = true,
        theme = 'catppuccin',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = { 'NvimTree' },
        always_divide_middle = false,
        globalstatus = true,
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = {
          'branch',
          'diff',
          'diagnostics',
        },
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
    },
  },

  -------------------
  -- Tab management
  -------------------
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      { 'tiagovla/scope.nvim', opts = { restore_state = true } },
    },
    event = 'VeryLazy',
    keys = {
      { '<C-t>', '<cmd>tabnew<cr>' }, -- New tab
      { '<Leader>q', '<cmd>bdelete<cr>' }, -- Close the current buffer
      { '<Leader>Q', '<cmd>bdelete!<cr>' }, -- Close the current buffer
      { '<C-Tab>', vim.cmd.tabnext }, -- Next tab
      { '<C-S-Tab>', vim.cmd.tabprevious }, -- Previous tab
      { '<Tab>', vim.cmd.bnext }, -- Next tab
      { '<S-Tab>', vim.cmd.bprev }, -- Previous tab
    },
    cmd = { 'BufferLineCloseLeft', 'BufferLineCloseRight' },
    opts = {
      options = {
        right_mouse_command = nil, -- can be a string | function | false, see "Mouse actions"
        left_mouse_command = 'buffer %d', -- can be a string | function, | false see "Mouse actions"
        middle_mouse_command = nil, -- can be a string | function, | false see "Mouse actions"
        diagnostics = 'nvim_lsp',
        indicator = { style = 'none' },
      },
    },
  },

  {
    'utilyre/barbecue.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'neovim/nvim-lspconfig',
      'smiteshp/nvim-navic',
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
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
    },
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      space_char_blankline = ' ',
      show_current_context = true,
      -- show_current_context_start = false,
      char = '▏',
      context_char = '▏',
      char_highlight_list = {
        'IndentBlanklineIndent1',
        'IndentBlanklineIndent2',
        'IndentBlanklineIndent3',
        'IndentBlanklineIndent4',
        'IndentBlanklineIndent5',
        'IndentBlanklineIndent6',
      },
      space_char_highlight_list = {
        'IndentBlanklineIndent1',
        'IndentBlanklineIndent2',
        'IndentBlanklineIndent3',
        'IndentBlanklineIndent4',
        'IndentBlanklineIndent5',
        'IndentBlanklineIndent6',
      },
      show_trailing_blankline_indent = false,
    },
  },
}
