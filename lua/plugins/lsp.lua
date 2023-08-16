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
    ['<C-x>'] = { mode = { 'n', 'i' }, action = vim.lsp.buf.code_action },
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
  'lua_ls',
  'pyright',
  'taplo',
  'rust_analyzer',
  'vimls',
  'yamlls',
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
  ['denols'] = { autostart = false, settings = { cmd_env = { NO_COLOR = false } } },

  -- Don't warn us about the alphabetical order of keys.
  ['yamlls'] = { settings = { yaml = { keyOrdering = false } } },

  -- In addition to the defaults, add in the twoslash-queries
  -- functionality to our client.
  -- ['tsserver'] = {
  -- 	on_attach = function(client, bufnr)
  -- 		with('twoslash-queries', function(twoslash)
  -- 			twoslash.attach(client, bufnr)
  -- 		end)
  -- 	end
  -- },
}

-- The default capabilities of our LSP clients
lsp.capabilities = function()
  return vim.lsp.protocol.make_client_capabilities()
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
  local config = {}
  config.base = { capabilities = lsp.capabilities() }
  config.server = type(lsp.config[server]) == 'table' and lsp.config[server] or {}
  config.override = {
    on_attach = function(client, bufnr)
      lsp.on_attach(client, bufnr)
      if type(config.server.on_attach) == 'function' then
        config.server.on_attach(client, bufnr)
      end
    end,
  }

  config.complete = vim.tbl_extend('force', config.base, config.server, config.override)

  require('lspconfig')[server].setup(config.complete)
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
    },
    config = lsp.setup_servers,
  },

  {
    'pmizio/typescript-tools.nvim',
    -- enabled = false,
    dependencies = { 'plenary.nvim', 'nvim-lspconfig', 'twoslash-queries.nvim' },
    opts = {
      on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false

        lsp.on_attach(client, bufnr)
        with('twoslash-queries', function(twoslash)
          twoslash.attach(client, bufnr)
        end)
      end,
      settings = {
        -- spawn additional tsserver instance to calculate diagnostics on it
        separate_diagnostic_server = true,

        -- "change"|"insert_leave" determine when the client asks the server about diagnostic
        publish_diagnostic_on = 'insert_leave',

        -- array of strings("fix_all"|"add_missing_imports"|"remove_unused")
        -- specify commands exposed as code_actions
        expose_as_code_action = {
          'fix_all',
          'remove_unused',
          'add_missing_imports',
        },

        -- string|nil - specify a custom path to `tsserver.js` file, if this is nil or file under path
        -- not exists then standard path resolution strategy is applied
        tsserver_path = nil,

        -- specify a list of plugins to load by tsserver, e.g., for support `styled-components`
        -- (see 💅 `styled-components` support section)
        tsserver_plugins = {},

        -- this value is passed to: https://nodejs.org/api/cli.html#--max-old-space-sizesize-in-megabytes
        -- memory limit in megabytes or "auto"(basically no limit)
        tsserver_max_memory = 'auto',

        -- described below
        tsserver_format_options = {
          insertSpaceAfterCommaDelimiter = true,
          insertSpaceAfterConstructor = false,
          insertSpaceAfterSemicolonInForStatements = true,
          insertSpaceBeforeAndAfterBinaryOperators = true,
          insertSpaceAfterKeywordsInControlFlowStatements = true,
          insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
          insertSpaceBeforeFunctionParenthesis = false,
          insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis = false,
          insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = false,
          insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = true,
          insertSpaceAfterOpeningAndBeforeClosingEmptyBraces = true,
          insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces = false,
          insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces = false,
          insertSpaceAfterTypeAssertion = false,
          placeOpenBraceOnNewLineForFunctions = false,
          placeOpenBraceOnNewLineForControlBlocks = false,
          semicolons = 'ignore',
          indentSwitchCase = true,
        },

        tsserver_file_preferences = {
          quotePreference = 'auto',
          importModuleSpecifierEnding = 'auto',
          jsxAttributeCompletionStyle = 'auto',
          allowTextChangesInNewFiles = true,
          providePrefixAndSuffixTextForRename = true,
          allowRenameOfImportPath = true,
          includeAutomaticOptionalChainCompletions = true,
          provideRefactorNotApplicableReason = true,
          generateReturnInDocTemplate = true,
          includeCompletionsForImportStatements = true,
          includeCompletionsWithSnippetText = true,
          includeCompletionsWithClassMemberSnippets = true,
          includeCompletionsWithObjectLiteralMethodSnippets = true,
          useLabelDetailsInCompletionEntries = true,
          allowIncompleteCompletions = true,
          displayPartsForJSDoc = true,
          disableLineTextInReferences = true,
          includeInlayParameterNameHints = 'none',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = false,
          includeInlayVariableTypeHints = false,
          includeInlayVariableTypeHintsWhenTypeMatchesName = false,
          includeInlayPropertyDeclarationTypeHints = false,
          includeInlayFunctionLikeReturnTypeHints = false,
          includeInlayEnumMemberValueHints = false,
        },
        -- mirror of VSCode's `typescript.suggest.completeFunctionCalls`
        complete_function_calls = false,
      },
    },
  },

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
      'JoosepAlviste/nvim-ts-context-commentstring',

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

      context_commentstring = {
        enable = true,
        enable_autocmd = false,
      },

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
