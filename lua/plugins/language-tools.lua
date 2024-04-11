local lazy_load = require('utils').import.lazy_load
return {
  {
    'windwp/nvim-autopairs',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      check_ts = true,
      ts_config = {
        javascript = { 'template_string' },
        typescript = { 'template_string' },
      },
    },
  },

  {
    'L3MON4D3/LuaSnip',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'honza/vim-snippets' },
    config = function()
      local types = require 'luasnip.util.types'
      -- Every unspecified option will be set to the default.
      require('luasnip').config.set_config {
        history = false,

        -- Update more often, :h events for more info.
        update_events = 'TextChanged,TextChangedI',

        -- Snippets aren't automatically removed if their text is deleted.
        -- `delete_check_events` determines on which events (:h events) a check for
        -- deleted snippets is performed.
        -- This can be especially useful when `history` is enabled.
        delete_check_events = 'TextChanged',

        ext_opts = {
          [types.choiceNode] = {
            active = { virt_text = { { 'choiceNode', 'Comment' } } },
          },
        },

        -- treesitter-hl has 100, use something higher (default is 200).
        ext_base_prio = 300,

        -- minimal increase in priority.
        ext_prio_increase = 1,
        enable_autosnippets = false,

        -- mapping for cutting selected text so it's usable as SELECT_DEDENT,
        -- SELECT_RAW or TM_SELECTED_TEXT (mapped via xmap).
        -- store_selection_keys = "<Tab>",

        -- luasnip uses this function to get the currently active filetype. This
        -- is the (rather uninteresting) default, but it's possible to use
        -- eg. treesitter for getting the current filetype by setting ft_func to
        -- require("luasnip.extras.filetype_functions").from_cursor (requires
        -- `nvim-treesitter/nvim-treesitter`). This allows correctly resolving
        -- the current filetype in eg. a markdown-code block or `vim.cmd()`.
        ft_func = function()
          return vim.split(vim.bo.filetype, '.', { plain = true })
        end,
      }

      require('luasnip.loaders.from_vscode').lazy_load()
      require('luasnip.loaders.from_snipmate').lazy_load()
      require 'snippets'
    end,
  },

  -- Autocompletion plugin
  {
    'hrsh7th/nvim-cmp',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
      'LuaSnip',

      -- LSP source for nvim-cmp
      'hrsh7th/cmp-nvim-lsp',

      -- Use completions from the buffer
      'hrsh7th/cmp-buffer',

      -- Use completions from the path
      'hrsh7th/cmp-path',

      -- Add completions to the cmdline
      'hrsh7th/cmp-cmdline',

      -- Snippet engines
      'saadparwaiz1/cmp_luasnip',

      -- Icons
      'onsails/lspkind.nvim',
    },

    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'

      -- If you want insert `(` after select function or method item

      local compare = cmp.config.compare
      local TriggerEvent = require('cmp.types').cmp.TriggerEvent

      -- Set completeopt to have a better completion experience
      vim.o.completeopt = 'menu,menuone,noselect'

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        enabled = function()
          -- disable completion if the cursor is `Comment` syntax group.
          local context = require 'cmp.config.context'

          -- keep command mode completion enabled when cursor is in a comment
          if vim.api.nvim_get_mode().mode == 'c' then
            return true
          else
            return not context.in_treesitter_capture 'comment' and not context.in_syntax_group 'Comment'
          end
        end,

        completion = {
          keyword_length = 1,
          autocomplete = {
            TriggerEvent.InsertEnter,
            TriggerEvent.TextChanged,
          },
        },

        formatting = {
          fields = { 'kind', 'abbr', 'menu' },
          format = require('lspkind').cmp_format {
            -- mode = 'text', -- show only text annotations
            mode = 'symbol', -- show only symbol annotations
            maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)

            -- The function below will be called before any actual modifications from lspkind
            -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
            before = function(entry, vim_item)
              return vim_item
            end,
          },
          -- format = function(entry, vim_item)
          --   local kind = require('lspkind').cmp_format { mode = 'symbol_text', maxwidth = 50, ellipsis_char = '...' }(entry, vim_item)
          --   local strings = vim.split(kind.kind, '%s', { trimempty = true })
          --   kind.kind = ' ' .. (strings[1] or '') .. ' '
          --   kind.menu = '    (' .. (strings[2] or '') .. ')'
          --
          --   return kind
          -- end,
        },

        mapping = cmp.mapping.preset.insert {
          ['<C-f>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),

          ['<CR>'] = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false },

          ['<A-j>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { 'i', 's' }),

          ['<A-k>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
        },

        -- sorting = {
        --   comparators = {
        --     compare.offset,
        --     compare.exact,
        --     compare.score,
        --     compare.kind,
        --     compare.sort_text,
        --     compare.length,
        --     compare.order,
        --   },
        -- },

        sources = cmp.config.sources {
          { name = 'nvim_lsp', group_index = 1 },
          { name = 'path', group_index = 1 },
          { name = 'luasnip', max_item_count = 4, group_index = 2 },
          --{ name = "nvim_lua" },
          { name = 'nvim_lsp_signature_help', group_index = 1 },
          --{ name = "buffer" },
        },

        preselect = cmp.PreselectMode.Item,
      }

      if not vim.g.autopair_confirm_attached then
        local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
        cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done { map_char = { tex = '' } })
        vim.g.autopair_confirm_attached = 1
      end

      cmp.setup.filetype('gitcommit', {
        -- You can specify the `cmp_git` source if you were installed it.
        sources = cmp.config.sources({ { name = 'cmp_git' } }, { { name = 'buffer' } }),
      })
    end,
  },

  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      signs = true, -- show icons in the signs column
      sign_priority = 8, -- sign priority

      -- keywords recognized as todo comments
      keywords = {
        FIX = {
          icon = ' ', -- icon used for the sign, and in search results
          color = 'error', -- can be a hex color, or a named color (see below)
          alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' }, -- a set of other keywords that all map to this FIX keywords
          -- signs = false, -- configure signs for some keywords individually
        },
        TODO = { icon = ' ', color = 'info' },
        HACK = { icon = ' ', color = 'warning' },
        WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
        PERF = { icon = ' ', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
        NOTE = { icon = ' ', color = 'hint', alt = { 'INFO' } },
        TEST = { icon = '⏲ ', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
      },

      gui_style = {
        fg = 'NONE', -- The gui style to use for the fg highlight group.
        bg = 'BOLD', -- The gui style to use for the bg highlight group.
      },

      -- when true, custom keywords will be merged with the defaults
      merge_keywords = true,

      -- highlighting of the line containing the todo comment
      -- * before: highlights before the keyword (typically comment characters)
      -- * keyword: highlights of the keyword
      -- * after: highlights after the keyword (todo text)
      highlight = {
        multiline = true, -- enable multine todo comments
        multiline_pattern = '^.', -- lua pattern to match the next multiline from the start of the matched keyword
        multiline_context = 10, -- extra lines that will be re-evaluated when changing a line
        before = '', -- "fg" or "bg" or empty
        keyword = 'wide', -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
        after = 'fg', -- "fg" or "bg" or empty
        pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
        comments_only = true, -- uses treesitter to match keywords in comments only
        max_line_len = 400, -- ignore lines longer than this
        exclude = {}, -- list of file types to exclude highlighting
      },
      -- list of named colors where we try to extract the guifg from the
      -- list of highlight groups or use the hex color if hl not found as a fallback
      colors = {
        error = { 'DiagnosticError', 'ErrorMsg', '#DC2626' },
        warning = { 'DiagnosticWarn', 'WarningMsg', '#FBBF24' },
        info = { 'DiagnosticInfo', '#2563EB' },
        hint = { 'DiagnosticHint', '#10B981' },
        default = { 'Identifier', '#7C3AED' },
        test = { 'Identifier', '#FF00FF' },
      },
      search = {
        command = 'rg',
        args = {
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
        },
        -- regex that will be used to match keywords.
        -- don't replace the (KEYWORDS) placeholder
        pattern = [[\b(KEYWORDS):]], -- ripgrep regex
        -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
      },
    },
  },

  {
    'LudoPinelli/comment-box.nvim',
    opts = {},
  },

  {
    'danymat/neogen',
    keys = {
      {
        '<leader>di',
        lazy_load { 'neogen', 'generate' },
				desc = 'Generate annotating documentation'
      },
    },
    opts = {
      snippet_engine = 'luasnip',
    },
    -- Uncomment next line if you want to follow only stable versions
    -- version = "*"
  },

  {
    'Wansmer/treesj',
    keys = { '<leader>m', '<leader>j', '<leader>s' },
    cmd = { 'TSJToggle', 'TSJSplit', 'TSJJoin' },
    dependencies = { 'nvim-treesitter' },
    opts = {
      ---@type boolean Use default keymaps (<space>m - toggle, <space>j - join, <space>s - split)
      use_default_keymaps = true,

      ---@type boolean Node with syntax error will not be formatted
      check_syntax_error = true,

      ---If line after join will be longer than max value,
      ---@type number If line after join will be longer than max value, node will not be formatted
      max_join_length = 120,

      ---Cursor behavior:
      ---hold - cursor follows the node/place on which it was called
      ---start - cursor jumps to the first symbol of the node being formatted
      ---end - cursor jumps to the last symbol of the node being formatted
      ---@type 'hold'|'start'|'end'
      cursor_behavior = 'hold',

      ---@type boolean Notify about possible problems or not
      notify = true,

      ---@type boolean Use `dot` for repeat action
      dot_repeat = true,

      ---@type nil|function Callback for treesj error handler. func (err_text, level, ...other_text)
      on_error = nil,

      ---@type table Presets for languages
      -- langs = {}, -- See the default presets in lua/treesj/langs
    },
  },

  {
    'johmsalas/text-case.nvim',
    dependencies = { 'telescope.nvim' },
    config = function()
      require('textcase').setup {}
      require('telescope').load_extension 'textcase'
    end,
    keys = {
      'ga', -- Default invocation prefix
      { 'ga.', '<cmd>TextCaseOpenTelescope<CR>', mode = { 'n', 'x' }, desc = 'Telescope' },
    },
    cmd = {
      -- NOTE: The Subs command name can be customized via the option "substitude_command_name"
      'Subs',
      'TextCaseOpenTelescope',
      'TextCaseOpenTelescopeQuickChange',
      'TextCaseOpenTelescopeLSPChange',
      'TextCaseStartReplacingCommand',
    },
    -- If you want to use the interactive feature of the `Subs` command right away, text-case.nvim
    -- has to be loaded on startup. Otherwise, the interactive feature of the `Subs` will only be
    -- available after the first executing of it or after a keymap of text-case.nvim has been used.
    lazy = false,
  },

  {
    'vuki656/package-info.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    ft = { 'json' },

    keys = {
      -- -- Show dependency versions
      -- vim.keymap.set({ "n" }, "<LEADER>ns", require("package-info").show, { silent = true, noremap = true })

      -- -- Hide dependency versions
      -- vim.keymap.set({ "n" }, "<LEADER>nc", require("package-info").hide, { silent = true, noremap = true })

      -- -- Toggle dependency versions
      -- vim.keymap.set({ "n" }, "<LEADER>nt", require("package-info").toggle, { silent = true, noremap = true })

      -- -- Update dependency on the line
      -- vim.keymap.set({ "n" }, "<LEADER>nu", require("package-info").update, { silent = true, noremap = true })

      -- -- Delete dependency on the line
      -- vim.keymap.set({ "n" }, "<LEADER>nd", require("package-info").delete, { silent = true, noremap = true })

      -- -- Install a new dependency
      -- vim.keymap.set({ "n" }, "<LEADER>ni", require("package-info").install, { silent = true, noremap = true })

      -- -- Install a different dependency version
      -- vim.keymap.set({ "n" }, "<LEADER>np", require("package-info").change_version, { silent = true, noremap = true })
    },

    opts = {
      colors = {
        up_to_date = '#3C4048', -- Text color for up to date dependency virtual text
        outdated = '#d19a66', -- Text color for outdated dependency virtual text
      },
      icons = {
        enable = true, -- Whether to display icons
        style = {
          up_to_date = '|  ', -- Icon for up to date dependencies
          outdated = '|  ', -- Icon for outdated dependencies
        },
      },
      autostart = true, -- Whether to autostart when `package.json` is opened
      hide_up_to_date = false, -- It hides up to date versions when displaying virtual text
      hide_unstable_versions = false, -- It hides unstable versions from version list e.g next-11.1.3-canary3
      -- Can be `npm`, `yarn`, or `pnpm`. Used for `delete`, `install` etc...
      -- The plugin will try to auto-detect the package manager based on
      -- `yarn.lock` or `package-lock.json`. If none are found it will use the
      -- provided one, if nothing is provided it will use `yarn`
      package_manager = 'pnpm',
    },
  },
}
