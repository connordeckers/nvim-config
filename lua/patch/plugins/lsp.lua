local packer = require 'packer'
local use = packer.use

---------------------------
--   LSP Config Items
---------------------------

LSPConfig = {
  formatting = {
    -- Format the document on write
    format_on_save = true,
  },

  ui = {
    -- The float dialog config for lsp/hover
    hover_float_config = { border = 'rounded' },
  },

  -- Highlight the token under the cursor on cursor-hold
  highlightTokenUnderCursor = true,

  mason = {
    config = {
      ui = {
        border = require 'patch.border',
        icons = {
          -- The list icon to use for installed packages.
          package_installed = ' ',
          -- The list icon to use for packages that are installing, or queued for installation.
          package_pending = ' ',
          -- The list icon to use for packages that are not installed.
          package_uninstalled = ' ',
        },
      },
    },
    lspconf_config = {},
    null_ls_config = {
      automatic_installation = true,
      automatic_setup = true,
    },
  },

  -- The typescript.nvim setup (faster than tsserver, plus more options)
  typescript_setup = {
    disable_commands = true,
    disable_formatting = true,
    debug = false,
    go_to_source_definition = { fallback = true },
  },

  -- The filetypes that prettier will run against
  prettier_filetypes = {
    'css',
    'graphql',
    'html',
    'javascript',
    'javascriptreact',
    'json',
    'less',
    'markdown',
    'scss',
    'typescript',
    'typescriptreact',
    'yaml',
  },

  lsp = {
    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    keymaps = {
      ['gD'] = vim.lsp.buf.declaration,
      ['gd'] = vim.lsp.buf.definition,
      -- ['K'] = vim.lsp.buf.hover,
      ['K'] = require('noice.lsp').hover,
      ['gi'] = vim.lsp.buf.implementation,
      ['gT'] = vim.lsp.buf.type_definition,
      ['<leader>rn'] = vim.lsp.buf.rename,
      ['<C-space>'] = vim.lsp.buf.code_action,
      ['gr'] = vim.lsp.buf.references,
      ['<leader>f'] = function()
        vim.lsp.buf.format { timeout_ms = 2500 }
      end,
      -- ["<C-K>"] = vim.lsp.buf.signature_help,
      -- ['<leader>wa'] = vim.lsp.buf.add_workspace_folder,
      -- ['<leader>wr'] = vim.lsp.buf.remove_workspace_folder,
      -- ['<leader>wl'] = function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
    },

    -- LSP servers to configure with their defaults.
    -- No overrides necessary!
    default = {
      'angularls',
      'bashls',
      'cssls',
      'html',
      'jsonls',
      'cssmodules_ls',
      'clangd',
      -- 'diagnosticls',
      'dockerls',
      'emmet_ls',
      'vimls',
      'yamlls',
      'rust_analyzer',
      'pyright',
    },

    -- These LSP servers have additional configuration applied.
    extended = {
      -- Qt
      ['qmlls'] = { cmd = { 'qmlls6' } },

      -- Lua
      ['sumneko_lua'] = {
        settings = {
          Lua = {
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = {
                -- Neovim bindings
                'vim',

                -- AwesomeWM bindings
                'awesome',
                'mouse',
                'client',
                'screen',
                'root',
              },
            },
            workspace = {
              -- Make the server aware of Neovim runtime files
              library = vim.tbl_deep_extend('force', vim.api.nvim_get_runtime_file('', true), {
                ['/usr/share/awesome/lib'] = true,
              }),

              -- Don't check for third party tools
              checkThirdParty = false,
            },
            -- Do not send telemetry data
            telemetry = { enable = false },
          },
        },
      },
    },
  },
}

-- Auto pair braces
use {
  'windwp/nvim-autopairs',
  config = function()
    require('nvim-autopairs').setup {
      check_ts = true,
      ts_config = {
        javascript = { 'template_string' },
        typescript = { 'template_string' },
      },
    }
  end,
}

---------------------------
--      Tree Sitter
---------------------------
use {
  'nvim-treesitter/nvim-treesitter',
  run = ':TSUpdate',
  requires = {
    'nvim-treesitter/playground',
    'nvim-treesitter/nvim-treesitter-textobjects',

    'windwp/nvim-ts-autotag',
    'theHamsta/nvim-treesitter-pairs',
    'JoosepAlviste/nvim-ts-context-commentstring',
  },

  config = function()
    require('nvim-treesitter.configs').setup {
      autotag = { enable = true },
      highlight = { enable = true },
      pairs = {
        enable = true,
        disable = {},
        highlight_pair_events = {}, -- e.g. {"CursorMoved"}, -- when to highlight the pairs, use {} to deactivate highlighting
        highlight_self = false, -- whether to highlight also the part of the pair under cursor (or only the partner)
        goto_right_end = false, -- whether to go to the end of the right partner or the beginning
        fallback_cmd_normal = "call matchit#Match_wrapper('',1,'n')", -- What command to issue when we can't find a pair (e.g. "normal! %")
        keymaps = {
          goto_partner = '<leader>%',
          delete_balanced = 'X',
        },
        delete_balanced = {
          only_on_first_char = false, -- whether to trigger balanced delete when on first character of a pair
          fallback_cmd_normal = nil, -- fallback command when no pair found, can be nil
          longest_partner = false, -- whether to delete the longest or the shortest pair when multiple found.
          -- E.g. whether to delete the angle bracket or whole tag in  <pair> </pair>
        },
      },
      textobjects = {
        select = {
          enable = true,

          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,

          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
            ['aC'] = '@conditional.outer',
            ['iC'] = '@conditional.inner',
            ['aS'] = '@tag.self-closing',
            ['ap'] = '@json.property',
          },
        },
      },
      refactor = {
        -- Highlights definition and usages of the current symbol under the cursor.
        highlight_definitions = {
          enable = true,
          -- Set to false if you have an `updatetime` of ~100.
          clear_on_cursor_move = true,
        },

        -- Renames the symbol under the cursor within the current scope (and current file).
        -- Disabled; prefer using LSP, as it can rename the same symbol outside this file.
        smart_rename = { enable = false },

        -- Provides "go to definition" for the symbol under the cursor, and lists the definitions from the current file.
        -- If you use goto_definition_lsp_fallback instead of goto_definition in the config below vim.lsp.buf.definition
        -- is used if nvim-treesitter can not resolve the variable. goto_next_usage/goto_previous_usage go to the next usage
        -- of the identifier under the cursor.
        navigation = {
          enable = true,
          keymaps = {
            goto_definition = 'gnd',
            list_definitions = 'gnD',
            list_definitions_toc = 'gO',
            goto_next_usage = '<a-*>',
            goto_previous_usage = '<a-#>',
          },
        },
      },

      context_commentstring = {
        enable = true,
        enable_autocmd = false,
      },

      -- View treesitter information directly in Neovim!
      playground = {
        enable = true,
        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
      },
    }
  end,
}

-- Add LSP support
use {
  'neovim/nvim-lspconfig',
  after = 'nvim-cmp',
  requires = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'jose-elias-alvarez/null-ls.nvim',
    'jose-elias-alvarez/typescript.nvim',
    'jayp0521/mason-null-ls.nvim',
  },
  config = function()
    -- Import our packages
    local lspconfig = require 'lspconfig'
    local null = require 'null-ls'
    local mason = require 'mason'
    local mason_lspconf = require 'mason-lspconfig'
    local mason_null_ls = require 'mason-null-ls'
    local typescript = require 'typescript'
    local cmp_lsp = require 'cmp_nvim_lsp'
    local lsp = vim.lsp.buf

    -- The null-ls sources to use
    local sources = {
      -- Code actions
      require 'patch.code-actions.typescript',
      null.builtins.code_actions.gitsigns,

      -- Diagnostics
      null.builtins.diagnostics.cmake_lint,
      -- null.builtins.diagnostics.codespell,
      null.builtins.diagnostics.commitlint,
      null.builtins.diagnostics.cpplint,
      null.builtins.diagnostics.gitlint,
      null.builtins.diagnostics.hadolint,
      -- null.builtins.diagnostics.flake8,

      -- Completion
      null.builtins.completion.tags,

      -- Formatting
      null.builtins.formatting.prettier.with { filetypes = LSPConfig.prettier_filetypes, timeout = 5000 },
      null.builtins.formatting.stylua,
      null.builtins.formatting.clang_format,
      null.builtins.formatting.black,
      null.builtins.formatting.isort,
    }

    -- LspFormatting AutoCommand group
    local lspFormatAUGroup = vim.api.nvim_create_augroup('LspFormatting', {})

    -- Mappings.
    -- Use an on_attach function to only map the following keys
    -- after the language server attaches to the current buffer
    local on_attach = function(client, bufnr)
      local opts = { noremap = true, silent = true, buffer = bufnr }
      for map, action in pairs(LSPConfig.lsp.keymaps) do
        vim.keymap.set('n', map, action, opts)
      end

      local navic_exists, navic = pcall(require, 'nvim-navic')
      -- Add support for the symbol path
      if navic_exists and client.server_capabilities.documentSymbolProvider then
        navic.attach(client, bufnr)
      end

      -- Add the autocommands for highlighting under the cursor
      if LSPConfig.highlightTokenUnderCursor and client.supports_method 'textDocument/documentHighlight' then
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, { callback = lsp.document_highlight, buffer = bufnr })
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, { callback = lsp.clear_references, buffer = bufnr })
      end

      -- Add the autocommands for formatting on save
      if LSPConfig.formatting.format_on_save and client.supports_method 'textDocument/formatting' then
        vim.api.nvim_clear_autocmds { group = lspFormatAUGroup, buffer = bufnr }
        vim.api.nvim_create_autocmd('BufWritePre', {
          group = lspFormatAUGroup,
          buffer = bufnr,
          callback = function()
            require('patch.utils.format').format_buffer(bufnr)
          end,
        })
      end
    end

    -- Overwrite handlers for LSP entries
    -- local handlers = {
    --   ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, LSPConfig.ui.hover_float_config),
    -- }

    -- Add additional capabilities supported by nvim-cmp
    local capabilities = cmp_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
    local default_server_opts = { on_attach = on_attach, capabilities = capabilities } -- , handlers = handlers

    -- At this point, it's just spinning things up.
    -- Nothing particularly interesting, despite being
    -- kinda important.
    typescript.setup(vim.tbl_deep_extend('force', LSPConfig.typescript_setup, { server = default_server_opts }))

    mason.setup(LSPConfig.mason.config)
    mason_lspconf.setup(LSPConfig.mason.lspconf_config)
    mason_null_ls.setup(LSPConfig.mason.null_ls_config)

    null.setup { sources = sources }

    local default_config = {}
    for _, key in pairs(LSPConfig.lsp.default) do
      default_config[key] = {}
    end

    -- The servers to configure
    local lsp_servers = vim.tbl_deep_extend('force', {}, default_config, LSPConfig.lsp.extended)

    for lsp_server, config in pairs(lsp_servers) do
      lspconfig[lsp_server].setup(vim.tbl_deep_extend('force', default_server_opts, config))
    end
  end,
}

use {
  'ray-x/lsp_signature.nvim',
  disable = true,
  config = function()
    local lsp_signature = require 'lsp_signature'
    lsp_signature.setup {
      -- This is mandatory, otherwise border config won't get registered.
      bind = true,

      -- If you want to hook lspsaga or other signature handler, pls set to false
      -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
      --
      -- set to 0 if you DO NOT want any API comments be shown
      -- This setting only take effect in insert mode, it does not affect signature help in normal
      -- mode, 10 by default
      doc_lines = 10,

      -- show hint in a floating window, set to false for virtual text only mode
      floating_window = false,

      -- try to place the floating above the current line when possible Note:
      -- will set to true when fully tested, set to false will use whichever side has more space
      -- this setting will be helpful if you do not want the PUM and floating win overlap
      floating_window_above_cur_line = true,

      -- adjust float windows x position.
      floating_window_off_x = 1,

      -- adjust float windows y position.
      floating_window_off_y = 1,

      -- set to true, the floating window will not auto-close until finish all parameters
      fix_pos = false,

      -- virtual hint enable
      hint_enable = true,
      hint_scheme = 'String',

      -- how your parameter will be highlight
      hi_parameter = 'LspSignatureActiveParameter',

      -- max height of signature floating_window, if content is more than max_height,
      -- you can scroll down to view the hiding contents
      max_height = 12,

      -- max_width of signature floating_window, line will be wrapped if exceed max_width
      max_width = 80,

      -- double, rounded, single, shadow, none
      handler_opts = { border = 'rounded' },

      -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58
      always_trigger = false,

      -- autoclose signature float win after x sec, disabled if nil.
      auto_close_after = nil,

      -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
      extra_trigger_chars = { '(', ',', '{', '[' },

      -- by default it will be on top of all floating windows, set to <= 50 send it to bottom
      zindex = 200,

      -- character to pad on left and right of signature can be ' ', or '|'  etc
      padding = '',

      -- disabled by default, allow floating win transparent value 1~100
      transparency = 25,

      -- if you using shadow as border use this set the opacity
      shadow_blend = 36,

      -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
      shadow_guibg = 'Black',

      -- default timer check interval set to lower value if you want to reduce latency
      timer_interval = 200,

      -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
      toggle_key = '<C-x>',
    }
  end,
}

use {
  'L3MON4D3/LuaSnip',
  requires = { 'honza/vim-snippets' },
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
    require 'patch.snippets.init'
  end,
}

-- Autocompletion plugin
use {
  'hrsh7th/nvim-cmp',
  after = 'LuaSnip',
  requires = {
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
  },

  config = function()
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'

    -- If you want insert `(` after select function or method item

    local compare = cmp.config.compare
    local TriggerEvent = require('cmp.types').cmp.TriggerEvent

    local has_words_before = function()
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
    end

    -- Set completeopt to have a better completion experience
    vim.o.completeopt = 'menu,menuone,noselect'

    local icons = {
      Text = '',
      Method = '',
      Function = '',
      Constructor = '⌘',
      Field = 'ﰠ',
      Variable = '',
      Class = 'ﴯ',
      Interface = '',
      Module = '',
      Property = 'ﰠ',
      Unit = '塞',
      Value = '',
      Enum = '',
      Keyword = '廓',
      Snippet = '',
      Color = '',
      File = '',
      Reference = '',
      Folder = '',
      EnumMember = '',
      Constant = '',
      Struct = 'פּ',
      Event = '',
      Operator = '',
      TypeParameter = '',
    }

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
        format = function(_, vim_item)
          vim_item.menu = vim_item.kind
          vim_item.kind = icons[vim_item.kind]

          return vim_item
        end,
      },

      mapping = cmp.mapping.preset.insert {
        ['<C-f>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),

        ['<CR>'] = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false },

        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.confirm { select = true }
          else
            fallback()
          end
        end, { 'i', 's' }),

        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
      },

      sorting = {
        comparators = {
          compare.offset,
          compare.exact,
          compare.score,
          compare.kind,
          compare.sort_text,
          compare.length,
          compare.order,
        },
      },

      sources = cmp.config.sources {
        { name = 'luasnip', max_item_count = 4 },
        { name = 'nvim_lsp' },
        --{ name = "nvim_lua" },
        -- { name = 'nvim_lsp_signature_help' },
        { name = 'path' },
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
}
