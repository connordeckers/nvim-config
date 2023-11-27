local with = require('utils').import.with
local lazy_load = require('utils').import.lazy_load
local mapkeys = require('utils').lsp.mapkeys

-- Our LSP object
local lsp = {}

lsp.keybinds = {
  -- Global mappings.
  -- See `:help vim.diagnostic.*` for documentation on any of the below functions
  ---@type table<string, string | function | KeybindTable | KeybindTable[]>
  global = {
    ['<leader>lq'] = vim.diagnostic.setloclist,
    ['<leader>lf'] = vim.diagnostic.open_float,
  },

  ---@type table<string, string | function | KeybindTable | KeybindTable[]>
  buffer = {
    ['K'] = lazy_load { 'noice.lsp', 'hover' },
    ['<C-space>'] = vim.lsp.buf.code_action,
    ['<leader>rn'] = vim.lsp.buf.rename,
    ['<leader>p'] = vim.lsp.buf.format,
    -- ['<leader>ldc'] = vim.lsp.buf.declaration,

    -- ['<A-k>'] = { mode = { 'n', 'i' }, action = vim.lsp.buf.signature_help },
    ['<C-x>'] = { mode = { 'n', 'i', 'v' }, action = vim.lsp.buf.code_action },
  },
}

-- The LSP servers we want to use.
-- These can be auto-installed by mason-lspconfig if they aren't yet available,
-- and the config can be overridden by adding one of these keys into the config
-- table below. Otherwise, an empty object is passed to the setup function.
lsp.servers = {
  'angularls',
  'bashls',
  'cssls',
  'cssmodules_ls',
  'denols',
  'dockerls',
  'emmet_ls',
  'html',
  'jsonls',
  'yamlls',
  'lua_ls',
  -- 'pyright',
  'taplo',
  'rust_analyzer',
  'tsserver',
  'vimls',
  -- 'vtsls',
}

-- Custom overrides for specific clients.
-- All other "unconfigured" servers are just
-- set up with the default configurations.
lsp.config = {
  -- ['efm'] = require 'config.efm',

  ['lua_ls'] = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        hint = {
          enable = true,
          arrayIndex = 'Auto',
          await = true,
          paramName = 'All',
          paramType = true,
          semicolon = 'SameLine',
          setType = false,
        },
      },
    },
  },

  -- Don't autostart deno. We only want to use it for
  -- specific circumstances.
  ['denols'] = {
    autostart = false,
    settings = {
      cmd_env = {
        NO_COLOR = false,
      },
    },

    after_lsp_config = function(lspconf)
      return {
        root_dir = lspconf.util.root_pattern('deno.json', 'deno.jsonc'),
      }
    end,
  },

  -- Don't warn us about the alphabetical order of keys.

  ['jsonls'] = {
    after_lsp_config = function(lspconf)
      --Enable (broadcasting) snippet capability for completion
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      return {
        capabilities = capabilities,
        settings = {
          json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
          },
        },
      }
    end,
  },
  ['yamlls'] = {
    settings = {
      yaml = {
        keyOrdering = false,
      },
    },
    after_lsp_config = function()
      return {
        settings = {
          yaml = {
            schemaStore = {
              -- You must disable built-in schemaStore support if you want to use
              -- this plugin and its advanced options like `ignore`.
              enable = false,
              -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
              url = '',
            },
            schemas = require('schemastore').yaml.schemas(),
          },
        },
      }
    end,
  },

  -- In addition to the defaults, add in the twoslash-queries
  -- functionality to our client.
  ['tsserver'] = {
    on_attach = function(client, bufnr)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false

      require('config.lsp').tsserver.TSPrebuild.on_attach(client, bufnr)

      with('twoslash-queries', function(twoslash)
        twoslash.attach(client, bufnr)
      end)
    end,
  },
}

-- The default capabilities of our LSP clients
lsp.capabilities = function()
  return vim.lsp.protocol.make_client_capabilities()
end

local function code_action_listener()
  local context = { diagnostics = vim.lsp.diagnostic.get_line_diagnostics() }
  local params = vim.lsp.util.make_range_params()
  params.context = context
  vim.lsp.buf_request(0, 'textDocument/codeAction', params, function(err, result, ctx, config)
    -- do something with result - e.g. check if empty and show some indication such as a sign
  end)
end

-- Global on_attach, to be called for all servers that
-- are set up. Additionally, custom ones can be added
-- to the config objects below, for specific servers
lsp.on_attach = function(client, bufnr)
  -- Add the autocommands for highlighting under the cursor
  if client.supports_method 'textDocument/documentHighlight' then
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, { callback = vim.lsp.buf.document_highlight, buffer = bufnr })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, { callback = vim.lsp.buf.clear_references, buffer = bufnr })
  end

  vim.api.nvim_create_autocmd('CursorHold', {
    buffer = bufnr,
    callback = function()
      local opts = {
        focusable = false,
        close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
        border = 'rounded',
        source = 'always',
        prefix = ' ',
        scope = 'cursor',
      }
      vim.diagnostic.open_float(nil, opts)
    end,
  })

  -- Add the autocommands for formatting on save
  if client.supports_method 'textDocument/formatting' then
    local lspFormatAUGroup = vim.api.nvim_create_augroup('LspFormatting', {})
    vim.api.nvim_clear_autocmds { group = lspFormatAUGroup, buffer = bufnr }
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = lspFormatAUGroup,
      buffer = bufnr,
      callback = function()
        require('utils.format').format_buffer(bufnr)
      end,
    })
  end
end

-- Configure an LSP server. This just takes a name, and can parse
-- the rest of the relevant configuration data.
lsp.configure = function(server)
  local nvim_lsp = require 'lspconfig'
  local config = {}
  config.base = { capabilities = lsp.capabilities() }
  config.server = type(lsp.config[server]) == 'table' and lsp.config[server] or {}

  if config.server.after_lsp_config ~= nil then
    config.server = vim.tbl_deep_extend('force', config.server, config.server.after_lsp_config(nvim_lsp) or {})
  end

  config.override = {
    on_attach = function(client, bufnr)
      lsp.on_attach(client, bufnr)
      if type(config.server.on_attach) == 'function' then
        config.server.on_attach(client, bufnr)
      end
    end,
  }

  config.complete = vim.tbl_deep_extend('force', config.base, config.server, config.override)

  nvim_lsp[server].setup(config.complete)
end

-- Setup all of our predefined servers.
-- This is nothing more than a loop over the keys in
-- lsp.servers, with a call to lsp.configure for each.
lsp.setup_servers = function()
  mapkeys(lsp.keybinds.global)

  -- Use LspAttach autocommand to only map the following keys
  -- after the language server attaches to the current buffer
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
      mapkeys(lsp.keybinds.buffer, ev.buf)
    end,
  })

  for _, server in ipairs(lsp.servers) do
    lsp.configure(server)
  end

  local function goto_definition(split_cmd)
    local util = vim.lsp.util
    local log = require 'vim.lsp.log'
    local api = vim.api

    -- note, this handler style is for neovim 0.5.1/0.6, if on 0.5, call with function(_, method, result)
    local handler = function(_, result, ctx)
      if result == nil or vim.tbl_isempty(result) then
        local _ = log.info() and log.info(ctx.method, 'No location found')
        return nil
      end

      if split_cmd then
        vim.cmd(split_cmd)
      end

      if vim.tbl_islist(result) then
        util.jump_to_location(result[1])

        if #result > 1 then
          util.set_qflist(util.locations_to_items(result, 'utf-8'))
          api.nvim_command 'copen'
          api.nvim_command 'wincmd p'
        end
      else
        util.jump_to_location(result)
      end
    end

    return handler
  end

  vim.lsp.handlers['textDocument/definition'] = goto_definition 'split'

  vim.diagnostic.config {
    virtual_text = {
      prefix = '⨯', -- Could be '●', '▎', 'x'
    },
  }
end

return {
  -- For a nicer experience in lua.
  {
    'folke/neoconf.nvim',
    cmd = 'Neoconf',
    lazy = true,
    opts = {},
  },

  {
    'folke/neodev.nvim',
    opts = { experimental = { pathStrict = true } },
    ft = { 'lua' },
  },

  -- Make everything just a bit friendlier to work with.
  {
    'williamboman/mason.nvim',
    opts = {},
    build = ':MasonUpdate',
    lazy = true,
  },

  {
    'williamboman/mason-lspconfig.nvim',
    opts = {
      automatic_installation = true, --[[ , handlers = { lsp.configure } ]]
    },
    dependencies = { 'mason.nvim' },
    lazy = true,
  },

  -- Handy feature for typescript
  {
    'marilari88/twoslash-queries.nvim',
    opts = {
      multi_line = true, -- to print types in multi line mode
      is_enabled = true, -- to keep enabled at startup
    },
    lazy = true,
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'neoconf.nvim',
      'mason-lspconfig.nvim',
      'b0o/schemastore.nvim',
    },
    config = lsp.setup_servers,
  },

  -- {
  --   'yioneko/nvim-vtsls',
  --   dependencies = { 'nvim-lspconfig', 'nvim-tree.lua' },
  --   opts = {
  --     -- customize handlers for commands
  --     -- handlers = {
  --     --   source_definition = function(err, locations) end,
  --     --   file_references = function(err, locations) end,
  --     --   code_action = function(err, actions) end,
  --     -- },
  --     -- automatically trigger renaming of extracted symbol
  --     refactor_auto_rename = true,
  --   },
  --   config = function(_, opts)
  --     require('vtsls').config(opts)

  --     vim.lsp.commands['editor.action.showReferences'] = function(command, ctx)
  --       local locations = command.arguments[3]
  --       local client = vim.lsp.get_client_by_id(ctx.client_id)
  --       if client and locations and #locations > 0 then
  --         local items = vim.lsp.util.locations_to_items(locations, client.offset_encoding)
  --         vim.fn.setloclist(0, {}, ' ', { title = 'References', items = items, context = ctx })
  --         vim.api.nvim_command 'lopen'
  --       end
  --     end

  --     local path_sep = package.config:sub(1, 1)

  --     local function trim_sep(path)
  --       return path:gsub(path_sep .. '$', '')
  --     end

  --     local function uri_from_path(path)
  --       return vim.uri_from_fname(trim_sep(path))
  --     end

  --     local function is_sub_path(path, folder)
  --       path = trim_sep(path)
  --       folder = trim_sep(path)
  --       if path == folder then
  --         return true
  --       else
  --         return path:sub(1, #folder + 1) == folder .. path_sep
  --       end
  --     end

  --     local function check_folders_contains(folders, path)
  --       for _, folder in pairs(folders) do
  --         if is_sub_path(path, folder) then
  --           return true
  --         end
  --       end
  --       return false
  --     end

  --     local function match_file_operation_filter(filter, name, type)
  --       if filter.scheme and filter.scheme ~= 'file' then
  --         -- we do not support uri scheme other than file
  --         return false
  --       end
  --       local pattern = filter.pattern
  --       local matches = pattern.matches

  --       if type ~= matches then
  --         return false
  --       end

  --       local regex_str = vim.fn.glob2regpat(pattern.glob)
  --       if vim.tbl_get(pattern, 'options', 'ignoreCase') then
  --         regex_str = '\\c' .. regex_str
  --       end
  --       return vim.regex(regex_str):match_str(name) ~= nil
  --     end

  --     local api = require 'nvim-tree.api'

  --     api.events.subscribe(api.events.Event.NodeRenamed, function(data)
  --       local stat = vim.loop.fs_stat(data.new_name)
  --       if not stat then
  --         return
  --       end

  --       local type = ({ file = 'file', directory = 'folder' })[stat.type]
  --       local clients = vim.lsp.get_clients {}
  --       for _, client in ipairs(clients) do
  --         if check_folders_contains(client.workspace_folders, data.old_name) then
  --           local filters = vim.tbl_get(client.server_capabilities, 'workspace', 'fileOperations', 'didRename', 'filters') or {}
  --           for _, filter in pairs(filters) do
  --             if match_file_operation_filter(filter, data.old_name, type) and match_file_operation_filter(filter, data.new_name, type) then
  --               client.notify('workspace/didRenameFiles', { files = { { oldUri = uri_from_path(data.old_name), newUri = uri_from_path(data.new_name) } } })
  --             end
  --           end
  --         end
  --       end
  --     end)
  --   end,
  -- },

  -- {
  --   'pmizio/typescript-tools.nvim',
  --   -- enabled = false,
  --   dependencies = { 'plenary.nvim', 'nvim-lspconfig', 'twoslash-queries.nvim', 'lbrayner/vim-rzip' },
  --   opts = function()
  --     return {
  --       root_dir = require('lspconfig').util.find_json_ancestor,
  --       single_file_support = false,
  --       on_attach = function(client, bufnr)
  --         client.server_capabilities.documentFormattingProvider = false
  --         client.server_capabilities.documentRangeFormattingProvider = false

  --         lsp.on_attach(client, bufnr)
  --         with('twoslash-queries', function(twoslash)
  --           twoslash.attach(client, bufnr)
  --         end)
  --       end,
  --       settings = {
  --         -- spawn additional tsserver instance to calculate diagnostics on it
  --         separate_diagnostic_server = true,

  --         -- "change"|"insert_leave" determine when the client asks the server about diagnostic
  --         publish_diagnostic_on = 'insert_leave',

  --         -- array of strings("fix_all"|"add_missing_imports"|"remove_unused")
  --         -- specify commands exposed as code_actions
  --         expose_as_code_action = {
  --           'fix_all',
  --           'remove_unused',
  --           'add_missing_imports',
  --         },

  --         -- string|nil - specify a custom path to `tsserver.js` file, if this is nil or file under path
  --         -- not exists then standard path resolution strategy is applied
  --         tsserver_path = nil,

  --         -- specify a list of plugins to load by tsserver, e.g., for support `styled-components`
  --         -- (see 💅 `styled-components` support section)
  --         tsserver_plugins = {},

  --         -- this value is passed to: https://nodejs.org/api/cli.html#--max-old-space-sizesize-in-megabytes
  --         -- memory limit in megabytes or "auto"(basically no limit)
  --         tsserver_max_memory = 'auto',

  --         -- described below
  --         tsserver_format_options = {
  --           insertSpaceAfterCommaDelimiter = true,
  --           insertSpaceAfterConstructor = false,
  --           insertSpaceAfterSemicolonInForStatements = true,
  --           insertSpaceBeforeAndAfterBinaryOperators = true,
  --           insertSpaceAfterKeywordsInControlFlowStatements = true,
  --           insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
  --           insertSpaceBeforeFunctionParenthesis = false,
  --           insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis = false,
  --           insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = false,
  --           insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = true,
  --           insertSpaceAfterOpeningAndBeforeClosingEmptyBraces = true,
  --           insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces = false,
  --           insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces = false,
  --           insertSpaceAfterTypeAssertion = false,
  --           placeOpenBraceOnNewLineForFunctions = false,
  --           placeOpenBraceOnNewLineForControlBlocks = false,
  --           semicolons = 'ignore',
  --           indentSwitchCase = true,
  --         },

  --         tsserver_file_preferences = {
  --           quotePreference = 'auto',
  --           importModuleSpecifierEnding = 'auto',
  --           jsxAttributeCompletionStyle = 'auto',
  --           allowTextChangesInNewFiles = true,
  --           providePrefixAndSuffixTextForRename = true,
  --           allowRenameOfImportPath = true,
  --           includeAutomaticOptionalChainCompletions = true,
  --           provideRefactorNotApplicableReason = true,
  --           generateReturnInDocTemplate = true,
  --           includeCompletionsForImportStatements = true,
  --           includeCompletionsWithSnippetText = true,
  --           includeCompletionsWithClassMemberSnippets = true,
  --           includeCompletionsWithObjectLiteralMethodSnippets = true,
  --           useLabelDetailsInCompletionEntries = true,
  --           allowIncompleteCompletions = true,
  --           displayPartsForJSDoc = true,
  --           disableLineTextInReferences = true,
  --           includeInlayParameterNameHints = 'none',
  --           includeInlayParameterNameHintsWhenArgumentMatchesName = false,
  --           includeInlayFunctionParameterTypeHints = false,
  --           includeInlayVariableTypeHints = false,
  --           includeInlayVariableTypeHintsWhenTypeMatchesName = false,
  --           includeInlayPropertyDeclarationTypeHints = false,
  --           includeInlayFunctionLikeReturnTypeHints = false,
  --           includeInlayEnumMemberValueHints = false,
  --         },
  --         -- mirror of VSCode's `typescript.suggest.completeFunctionCalls`
  --         complete_function_calls = false,
  --       },
  --     }
  --   end,
  -- },

  {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPost', 'BufNewFile' },
    cmd = {
      'TSInstall',
      'TSInstallSync',
      'TSInstallInfo',
      'TSUpdate',
      'TSUpdateSync',
      'TSUninstall',
      'TSBufEnable',
      'TSBufDisable',
      'TSBufToggle',
      'TSEnable',
      'TSDisable',
      'TSToggle',
      'TSModuleInfo',
      'TSEditQuery',
      'TSEditQueryUserAfter',
    },
    dependencies = {
      'nvim-treesitter/playground',
      'nvim-treesitter/nvim-treesitter-textobjects',

      -- 'windwp/nvim-ts-autotag',
      'theHamsta/nvim-treesitter-pairs',
      {
        'JoosepAlviste/nvim-ts-context-commentstring',
        opts = { enable_autocmd = false },
        init = function()
          vim.g.skip_ts_context_commentstring_module = true
        end,
      },

      { 'bennypowers/template-literal-comments.nvim', opts = {} },
    },

    opts = {
      -- Automatically install missing parsers when entering buffer
      -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
      auto_install = true,

      -- autotag = { enable = true },
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
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<CR>',
          node_incremental = '<CR>',
          scope_incremental = '<S-CR>',
          node_decremental = '<BS>',
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

      -- context_commentstring = {
      --   enable = true,
      --   enable_autocmd = false,
      -- },

      -- View treesitter information directly in Neovim!
      playground = {
        enable = true,
        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
      },
    },

    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,

    build = function()
      require('nvim-treesitter.install').update { with_sync = true }
    end,
  },
}
