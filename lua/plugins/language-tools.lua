local function lazy_load(package, method)
  return function(...)
    local success, pkg = pcall(require, package)
    if success then
      pkg[method](...)
    end
  end
end

local function with(package, callback)
  local exists, pkg = pcall(require, package)
  if not exists then
    return nil
  end

  return callback(pkg)
end

local rounded_border = {
  { '╭', 'FloatBorder' },
  { '─', 'FloatBorder' },
  { '╮', 'FloatBorder' },
  { '│', 'FloatBorder' },
  { '╯', 'FloatBorder' },
  { '─', 'FloatBorder' },
  { '╰', 'FloatBorder' },
  { '│', 'FloatBorder' },
}

return {

  -- {
  --   'junnplus/lsp-setup.nvim',
  --   event = { 'BufReadPost', 'BufNewFile' },
  --   dependencies = {
  --     'neovim/nvim-lspconfig',
  --     { 'folke/neoconf.nvim', cmd = 'Neoconf', lazy = false, opts = {} },
  --     { 'folke/neodev.nvim', opts = { experimental = { pathStrict = true } } },

  --     'williamboman/mason.nvim',
  --     'williamboman/mason-lspconfig.nvim',
  --     'Issafalcon/lsp-overloads.nvim',
  --     -- 'lvimuser/lsp-inlayhints.nvim',
  --     {
  --       'marilari88/twoslash-queries.nvim',
  --       opts = {
  --         multi_line = true, -- to print types in multi line mode
  --         is_enabled = true, -- to keep enabled at startup
  --       },
  --     },
  --     'joeveiga/ng.nvim',
  --   },

  --   opts = {
  --     default_mappings = false,
  --     mappings = {
  --       ['K'] = lazy_load('noice.lsp', 'hover'),
  --       ['<leader>rn'] = vim.lsp.buf.rename,
  --       ['<C-space>'] = vim.lsp.buf.code_action,
  --     },

  --     servers = {
  --       -- Shell languages
  --       bashls = {},

  --       -- Editor specific features
  --       lua_ls = {
  --         settings = {
  --           Lua = {
  --             workspace = { checkThirdParty = false },
  --             hint = {
  --               enable = true,
  --               arrayIndex = 'Auto',
  --               await = true,
  --               paramName = 'All',
  --               paramType = true,
  --               semicolon = 'SameLine',
  --               setType = false,
  --             },
  --           },
  --         },
  --       },
  --       vimls = {},

  --       -- System languages
  --       dockerls = {},
  --       denols = {
  --         autostart = false,
  --         settings = { cmd_env = { NO_COLOR = false } },
  --       },
  --       yamlls = {
  --         settings = {
  --           yaml = {
  --             -- FIX mapKeyOrder warning
  --             keyOrdering = false,
  --           },
  --         },
  --       },
  --       rust_analyzer = {},
  --       pyright = {},

  --       -- Web languages
  --       angularls = {},
  --       cssls = {},
  --       html = {},
  --       jsonls = {},
  --       cssmodules_ls = {},
  --       emmet_ls = {},
  --       tsserver = {},
  --     },
  --     capabilities = vim.lsp.protocol.make_client_capabilities(),
  --     on_attach = function(client, bufnr)
  --       if client.name == 'tsserver' then
  --         with('twoslash-queries', function(twoslash)
  --           twoslash.attach(client, bufnr)
  --         end)
  --       end

  --       -- Add the autocommands for highlighting under the cursor
  --       if client.supports_method 'textDocument/documentHighlight' then
  --         vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, { callback = vim.lsp.buf.document_highlight, buffer = bufnr })
  --         vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, { callback = vim.lsp.buf.clear_references, buffer = bufnr })
  --       end

  --       -- Add the autocommands for formatting on save
  --       if client.supports_method 'textDocument/formatting' then
  --         local lspFormatAUGroup = vim.api.nvim_create_augroup('LspFormatting', {})
  --         vim.api.nvim_clear_autocmds { group = lspFormatAUGroup, buffer = bufnr }
  --         vim.api.nvim_create_autocmd('BufWritePre', {
  --           group = lspFormatAUGroup,
  --           buffer = bufnr,
  --           callback = function()
  --             require('utils.format').format_buffer(bufnr)
  --           end,
  --         })
  --       end
  --     end,
  --   },

  --   -- config = function(_, opts)
  --   --   vim.lsp.set_log_level 'debug'
  --   --   require('lsp-setup').setup(opts)
  --   -- end,
  -- },

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

  -- cmdline tools and lsp servers
  -- {
  --   'williamboman/mason.nvim',
  --   cmd = 'Mason',
  --   keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' } },
  --   opts = {
  --     ui = {
  --       border = rounded_border,
  --       icons = {
  --         -- The list icon to use for installed packages.
  --         package_installed = ' ',
  --         -- The list icon to use for packages that are installing, or queued for installation.
  --         package_pending = ' ',
  --         -- The list icon to use for packages that are not installed.
  --         package_uninstalled = ' ',
  --       },
  --     },
  --     ensure_installed = {},
  --   },
  --   ---@param opts MasonSettings | {ensure_installed: string[]}
  --   config = function(_, opts)
  --     require('mason').setup(opts)
  --     local mr = require 'mason-registry'
  --     local function ensure_installed()
  --       for _, tool in ipairs(opts.ensure_installed) do
  --         local p = mr.get_package(tool)
  --         if not p:is_installed() then
  --           p:install()
  --         end
  --       end
  --     end

  --     if mr.refresh then
  --       mr.refresh(ensure_installed)
  --     else
  --       ensure_installed()
  --     end
  --   end,
  -- },

  -- {
  --   'jay-babu/mason-nvim-dap.nvim',
  --   event = { 'BufReadPost', 'BufNewFile' },
  --   opts = {},
  --   dependencies = {
  --     { 'mfussenegger/nvim-dap' },
  --     { 'theHamsta/nvim-dap-virtual-text', opts = {} },
  --     { 'rcarriga/nvim-dap-ui' },
  --     { 'LiadOz/nvim-dap-repl-highlights' },
  --   },
  -- },

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
          { name = 'nvim_lsp', group_index = 2 },
          { name = 'path', group_index = 2 },
          { name = 'luasnip', max_item_count = 4, group_index = 3 },
          --{ name = "nvim_lua" },
          { name = 'nvim_lsp_signature_help', group_index = 2 },
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
}
