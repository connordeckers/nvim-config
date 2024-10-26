local with = require('utils').import.with
local lazy_load = require('utils').import.lazy_load
local mapkeys = require('utils').lsp.mapkeys

-- Our LSP object
local lsp = {}
lsp.helpers = {}

function lsp.helpers.show_definition_in_split(split_cmd)
	local log = require 'vim.lsp.log'

	-- note, this handler style is for neovim 0.5.1/0.6, if on 0.5, call with function(_, method, result)
	local handler = function(_, result, ctx)
		if result == nil or vim.tbl_isempty(result) then
			local _ = log.info() and log.info(ctx.method, 'No location found')
			return nil
		end

		if split_cmd then
			vim.cmd(split_cmd)
		end

		if vim.islist(result) then
			vim.lsp.util.jump_to_location(result[1])

			if #result > 1 then
				vim.lsp.util.set_qflist(vim.lsp.util.locations_to_items(result, 'utf-8'))
				vim.api.nvim_command 'copen'
				vim.api.nvim_command 'wincmd p'
			end
		else
			vim.lsp.util.jump_to_location(result)
		end
	end

	return handler
end

function lsp.helpers.setup_codelens_refresh(client, bufnr)
	local status_ok, codelens_supported = pcall(function()
		return client.supports_method 'textDocument/codeLens'
	end)

	if not status_ok or not codelens_supported then
		return
	end

	local group = 'lsp_code_lens_refresh'
	local cl_events = { 'BufEnter', 'InsertLeave' }
	local ok, cl_autocmds = pcall(vim.api.nvim_get_autocmds, {
		group = group,
		buffer = bufnr,
		event = cl_events,
	})

	if ok and #cl_autocmds > 0 then
		return
	end

	vim.api.nvim_create_augroup(group, { clear = false })
	vim.api.nvim_create_autocmd(cl_events, {
		group = group,
		buffer = bufnr,
		callback = vim.lsp.codelens.refresh,
	})
end

function lsp.helpers.setup_document_highlight(client, bufnr)
	-- Add the autocommands for highlighting under the cursor
	if client.supports_method 'textDocument/documentHighlight' then
		vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
			callback = vim.lsp.buf.document_highlight,
			buffer = bufnr,
		})

		vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
			callback = vim.lsp.buf.clear_references,
			buffer = bufnr,
		})
	end
end

function lsp.helpers.show_diagnostic(client, bufnr)
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
end

function lsp.helpers.format_on_save(client, bufnr)
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
		-- ['<leader>p'] = vim.lsp.buf.format,
		['<leader>p'] = function(bufnr)
			require('utils.format').format_buffer(bufnr)
		end,
		-- ['<leader>ldc'] = vim.lsp.buf.declaration,

		['<leader>k'] = vim.lsp.codelens.run,
	},
}

-- The LSP servers we want to use.
-- These can be auto-installed by mason-lspconfig if they aren't yet available,
-- and the config can be overridden by adding one of these keys into the config
-- table below. Otherwise, an empty object is passed to the setup function.
lsp.servers = {
	'angularls',
	'bashls',
	-- 'biome',
	-- 'tsserver',
	'cssls',
	'cssmodules_ls',
	'denols',
	'dockerls',
	'emmet_ls',
	-- 'eslint',
	'html',
	'jsonls',
	'yamlls',
	'lua_ls',
	'nushell',
	'pyright',
	'taplo',
	-- 'rust_analyzer',
	-- 'xmlformatter',
	'volar', -- load before tsserver
	'ts_ls',
	'vimls',
	-- 'vuels',
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
		on_init = function(client)
			local path = client.workspace_folders[1].name

			if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
				return
			end

			client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
				runtime = {
					-- Tell the language server which version of Lua you're using
					-- (most likely LuaJIT in the case of Neovim)
					version = 'LuaJIT',
				},
				-- Make the server aware of Neovim runtime files
				workspace = {
					checkThirdParty = false,
					library = {
						vim.env.VIMRUNTIME,
						-- Depending on the usage, you might want to add additional paths here.
						-- "${3rd}/luv/library"
						-- "${3rd}/busted/library",
					},
					-- or pull in all of 'runtimepath'. NOTE: this is a lot slower
					-- library = vim.api.nvim_get_runtime_file("", true)
				},
			})
		end,
	},
	-- Don't autostart deno. We only want to use it for
	-- specific circumstances.
	['denols'] = {
		-- autostart = false,
		-- settings = { cmd_env = { NO_COLOR = false } },

		-- after_lsp_config = function(lspconf)
		--   return { root_dir = lspconf.util.root_pattern('deno.json', 'deno.jsonc') }
		-- end,
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
	-- ['rust_analyzer'] = {
	--   on_attach = function(client, bufnr)
	--     client.server_capabilities.textDocument = client.server_capabilities.textDocument or {}
	--     client.server_capabilities.textDocument.codeLens = true

	--     vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
	--       callback = vim.lsp.codelens.refresh,
	--       buffer = bufnr,
	--     })
	--   end,
	--   settings = {
	--     ['rust-analyzer'] = {
	--       checkOnSave = { command = 'clippy' },
	--     },
	--   },
	-- },

	['biome'] = {
		--- @type vim.lsp.client.on_attach_cb
		on_attach = function(client, bufnr)
			client.server_capabilities.documentFormattingProvider = true
			client.server_capabilities.documentRangeFormattingProvider = true
		end,
	},
	-- In addition to the defaults, add in the twoslash-queries
	-- functionality to our client.
	['ts_ls'] = {
		-- init_options = {
		--   plugins = {
		--     {
		--       name = '@vue/typescript-plugin',
		--       location = vim.fn.expand '$HOME/.local/share/pnpm/global/5/node_modules/@vue/typescript-plugin',
		--       languages = { 'javascript', 'typescript', 'vue' },
		--     },
		--   },
		-- },

		after_lsp_config = function(lspconf)
			return {
				single_file_support = false,
			}
		end,

		--- @type vim.lsp.client.on_attach_cb
		on_attach = function(client, bufnr)
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false

			require('config.lsp').tsserver.TSPrebuild.on_attach(client, bufnr)
			-- require('workspace-diagnostics').populate_workspace_diagnostics(client, bufnr)

			with('twoslash-queries', function(twoslash)
				twoslash.attach(client, bufnr)
			end)
		end,
		filetypes = {
			-- As of 2.0.0, Volar no longer supports TypeScript itself. Instead, a plugin adds Vue support to this language server.
			-- IMPORTANT: It is crucial to ensure that @vue/typescript-plugin and volar are of identical versions.
			'vue',

			'javascript',
			'javascriptreact',
			'javascript.jsx',
			'typescript',
			'typescriptreact',
			'typescript.tsx',
		},
	},
	['volar'] = { filetypes = { 'vue' } },
}

-- The default capabilities of our LSP clients
lsp.capabilities = function()
	return vim.lsp.protocol.make_client_capabilities()
end

-- local function code_action_listener()
--   local context = { diagnostics = vim.lsp.diagnostic.get_line_diagnostics() }
--   local params = vim.lsp.util.make_range_params()
--   params.context = context
--   vim.lsp.buf_request(0, 'textDocument/codeAction', params, function(err, result, ctx, config)
--     -- do something with result - e.g. check if empty and show some indication such as a sign
--   end)
-- end

-- Global on_attach, to be called for all servers that
-- are set up. Additionally, custom ones can be added
-- to the config objects below, for specific servers
lsp.on_attach = function(client, bufnr)
	lsp.helpers.format_on_save(client, bufnr)
	-- lsp.helpers.show_diagnostic(client, bufnr)
	lsp.helpers.setup_codelens_refresh(client, bufnr)
	lsp.helpers.setup_document_highlight(client, bufnr)

	-- if client.capabilities.get then

	-- end
end

-- Configure an LSP server. This just takes a name, and can parse
-- the rest of the relevant configuration data.
lsp.configure = function(server)
	if require('neoconf').get(server .. '.disable') then
		return
	end

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
lsp.setup = {
	before_setup = function()
		mapkeys(lsp.keybinds.global)

		-- Use LspAttach autocommand to only map the following keys
		-- after the language server attaches to the current buffer
		vim.api.nvim_create_autocmd('LspAttach', {
			group = vim.api.nvim_create_augroup('UserLspConfig', {}),
			callback = function(ev)
				mapkeys(lsp.keybinds.buffer, ev.buf)
			end,
		})
	end,
	create_servers = function()
		for _, server in ipairs(lsp.servers) do
			lsp.configure(server)
		end
	end,
	after_setup = function()
		-- vim.lsp.handlers['textDocument/definition'] = lsp.helpers.show_definition_in_split 'split'

		vim.diagnostic.config {
			-- virtual_text = false,
			virtual_text = {
				prefix = '⨯', -- Could be '●', '▎', 'x'
				severity = { max = vim.diagnostic.severity.INFO },
			},
			virtual_lines = {
				severity = { min = vim.diagnostic.severity.WARN },
			},
		}
	end,
}

lsp.setup_servers = function()
	lsp.setup.before_setup()
	lsp.setup.create_servers()
	lsp.setup.after_setup()

	-- require 'utils.vuejs-lsp'
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
			automatic_installation = true,
			-- handlers = { lsp.configure },
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
	--   'pmizio/typescript-tools.nvim',
	--   dependencies = { 'plenary.nvim', 'nvim-lspconfig' },
	--   ft = { 'typescript', 'javascript', 'typescriptreact' },
	--   opts = {
	--     on_attach = function(client, bufnr)
	--       client.server_capabilities.documentFormattingProvider = false
	--       client.server_capabilities.documentRangeFormattingProvider = false

	--       require('config.lsp').tsserver.TSPrebuild.on_attach(client, bufnr)

	--       with('twoslash-queries', function(twoslash)
	--         twoslash.attach(client, bufnr)
	--       end)
	--     end,
	--     settings = { expose_as_code_action = 'all' },
	--   },
	-- },

	{
		'artemave/workspace-diagnostics.nvim',
		lazy = true,
	},

	{
		'saecki/crates.nvim',
		dependencies = { 'plenary.nvim' },
		opts = {},
		ft = 'rust',
	},

	{
		'simrat39/rust-tools.nvim',
		dependencies = {
			'nvim-lspconfig',
			-- Debugging
			'plenary.nvim',
			'nvim-dap',
		},
		ft = 'rust',
		config = function()
			local rt = require 'rust-tools'
			local mason_path = vim.fn.glob(vim.fn.stdpath 'data' .. '/mason/')

			local codelldb_path = mason_path .. 'bin/codelldb'
			local liblldb_path = mason_path .. 'packages/codelldb/extension/lldb/lib/liblldb'
			local this_os = vim.loop.os_uname().sysname

			-- The path in windows is different
			if this_os:find 'Windows' then
				codelldb_path = mason_path .. 'packages\\codelldb\\extension\\adapter\\codelldb.exe'
				liblldb_path = mason_path .. 'packages\\codelldb\\extension\\lldb\\bin\\liblldb.dll'
			else
				-- The liblldb extension is .so for linux and .dylib for macOS
				liblldb_path = liblldb_path .. (this_os == 'Linux' and '.so' or '.dylib')
			end

			rt.setup {
				tools = {
					executor = require('rust-tools/executors').termopen, -- can be quickfix or termopen
					reload_workspace_from_cargo_toml = true,
					runnables = { use_telescope = true },
					-- inlay_hints = {
					--   auto = true,
					--   only_current_line = false,
					--   show_parameter_hints = false,
					--   parameter_hints_prefix = '<-',
					--   other_hints_prefix = '=>',
					--   max_len_align = false,
					--   max_len_align_padding = 1,
					--   right_align = false,
					--   right_align_padding = 7,
					--   highlight = 'Comment',
					-- },

					hover_actions = { border = 'rounded' },
					on_initialized = function()
						vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter', 'CursorHold', 'InsertLeave' }, {
							pattern = { '*.rs' },
							callback = function()
								pcall(vim.lsp.codelens.refresh)
							end,
						})
					end,
				},
				dap = {
					-- adapter= codelldb_adapter,
					adapter = require('rust-tools.dap').get_codelldb_adapter(codelldb_path, liblldb_path),
				},
				server = {
					on_attach = function(client, bufnr)
						lsp.setup.before_setup()

						-- Hover actions
						-- vim.keymap.set('n', 'K', rt.hover_actions.hover_actions, { buffer = bufnr })

						-- Code action groups
						vim.keymap.set('n', '<Leader>a', rt.code_action_group.code_action_group, { buffer = bufnr })

						lsp.on_attach(client, bufnr)
						lsp.setup.after_setup()
					end,
					capabilities = lsp.capabilities(),
					settings = {
						['rust-analyzer'] = {
							lens = { enable = true },
							checkOnSave = {
								enable = true,
								command = 'clippy',
							},
						},
					},
				},
			}
		end,
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

			'windwp/nvim-ts-autotag',
			'theHamsta/nvim-treesitter-pairs',
			{
				'JoosepAlviste/nvim-ts-context-commentstring',
				opts = {
					enable_autocmd = false,
					languages = {
						kdl = { __default = '// %s', __multiline = '/* %s */' },
					},
				},
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
			autotag = { enable = true },
			highlight = {
				enable = true,
				-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
				-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
				-- Using this option may slow down your editor, and you may see some duplicate highlights.
				-- Instead of true it can also be a list of languages
				additional_vim_regex_highlighting = false,
			},
			pairs = {
				enable = true,
				disable = {},
				highlight_pair_events = {},                                   -- e.g. {"CursorMoved"}, -- when to highlight the pairs, use {} to deactivate highlighting
				highlight_self = false,                                       -- whether to highlight also the part of the pair under cursor (or only the partner)
				goto_right_end = false,                                       -- whether to go to the end of the right partner or the beginning
				fallback_cmd_normal = "call matchit#Match_wrapper('',1,'n')", -- What command to issue when we can't find a pair (e.g. "normal! %")
				keymaps = {
					goto_partner = '<leader>%',
					delete_balanced = 'X',
				},
				delete_balanced = {
					only_on_first_char = false, -- whether to trigger balanced delete when on first character of a pair
					fallback_cmd_normal = nil,  -- fallback command when no pair found, can be nil
					longest_partner = false,    -- whether to delete the longest or the shortest pair when multiple found.
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

	{
		'chrisgrieser/nvim-various-textobjs',
		keys = {
			{ 'ii', "<cmd>lua require('various-textobjs').indentation('inner', 'inner')<CR>",   mode = { 'o', 'x' } },
			{ 'ai', "<cmd>lua require('various-textobjs').indentation('outer', 'inner')<CR>",   mode = { 'o', 'x' } },
			{ 'iI', "<cmd>lua require('various-textobjs').indentation('inner', 'inner')<CR>",   mode = { 'o', 'x' } },
			{ 'aI', "<cmd>lua require('various-textobjs').indentation('outer', 'outer')<CR>",   mode = { 'o', 'x' } },
			{ 'R',  "<cmd>lua require('various-textobjs').restOfIndentation()<CR>",             mode = { 'o', 'x' } },
			{ 'ig', "<cmd>lua require('various-textobjs').greedyOuterIndentation('inner')<CR>", mode = { 'o', 'x' } },
			{ 'ag', "<cmd>lua require('various-textobjs').greedyOuterIndentation('outer')<CR>", mode = { 'o', 'x' } },
			{ 'iS', "<cmd>lua require('various-textobjs').subword('inner')<CR>",                mode = { 'o', 'x' } },
			{ 'aS', "<cmd>lua require('various-textobjs').subword('outer')<CR>",                mode = { 'o', 'x' } },
			{ 'C',  "<cmd>lua require('various-textobjs').toNextClosingBracket()<CR>",          mode = { 'o', 'x' } },
			{ 'Q',  "<cmd>lua require('various-textobjs').toNextQuotationMark()<CR>",           mode = { 'o', 'x' } },
			{ 'r',  "<cmd>lua require('various-textobjs').restOfParagraph()<CR>",               mode = { 'o', 'x' } },
			{ 'gG', "<cmd>lua require('various-textobjs').entireBuffer()<CR>",                  mode = { 'o', 'x' } },
			{ 'n',  "<cmd>lua require('various-textobjs').nearEoL()<CR>",                       mode = { 'o', 'x' } },
			{ 'i_', "<cmd>lua require('various-textobjs').lineCharacterwise('inner')<CR>",      mode = { 'o', 'x' } },
			{ 'a_', "<cmd>lua require('various-textobjs').lineCharacterwise('outer')<CR>",      mode = { 'o', 'x' } },
			{ '|',  "<cmd>lua require('various-textobjs').column()<CR>",                        mode = { 'o', 'x' } },
			{ 'iv', "<cmd>lua require('various-textobjs').value('inner')<CR>",                  mode = { 'o', 'x' } },
			{ 'av', "<cmd>lua require('various-textobjs').value('outer')<CR>",                  mode = { 'o', 'x' } },
			{ 'ik', "<cmd>lua require('various-textobjs').key('inner')<CR>",                    mode = { 'o', 'x' } },
			{ 'ak', "<cmd>lua require('various-textobjs').key('outer')<CR>",                    mode = { 'o', 'x' } },
			{ 'L',  "<cmd>lua require('various-textobjs').url()<CR>",                           mode = { 'o', 'x' } },
			{ 'in', "<cmd>lua require('various-textobjs').number('inner')<CR>",                 mode = { 'o', 'x' } },
			{ 'an', "<cmd>lua require('various-textobjs').number('outer')<CR>",                 mode = { 'o', 'x' } },
			{ '!',  "<cmd>lua require('various-textobjs').diagnostic()<CR>",                    mode = { 'o', 'x' } },
			{ 'iz', "<cmd>lua require('various-textobjs').closedFold('inner')<CR>",             mode = { 'o', 'x' } },
			{ 'az', "<cmd>lua require('various-textobjs').closedFold('outer')<CR>",             mode = { 'o', 'x' } },
			{ 'im', "<cmd>lua require('various-textobjs').chainMember('inner')<CR>",            mode = { 'o', 'x' } },
			{ 'am', "<cmd>lua require('various-textobjs').chainMember('outer')<CR>",            mode = { 'o', 'x' } },
			{ 'gw', "<cmd>lua require('various-textobjs').visibleInWindow()<CR>",               mode = { 'o', 'x' } },
			{ 'gW', "<cmd>lua require('various-textobjs').restOfWindow()<CR>",                  mode = { 'o', 'x' } },

			{
				'il',
				"<cmd>lua require('various-textobjs').mdlink('inner')<CR>",
				mode = { 'o', 'x' },
				ft = { 'markdown', 'toml' },
			},
			{
				'al',
				"<cmd>lua require('various-textobjs').mdlink('outer')<CR>",
				mode = { 'o', 'x' },
				ft = { 'markdown', 'toml' },
			},

			{
				'iC',
				"<cmd>lua require('various-textobjs').mdFencedCodeBlock('inner')<CR>",
				mode = { 'o', 'x' },
				ft = { 'markdown' },
			},
			{
				'aC',
				"<cmd>lua require('various-textobjs').mdFencedCodeBlock('outer')<CR>",
				mode = { 'o', 'x' },
				ft = { 'markdown' },
			},

			{
				'ic',
				"<cmd>lua require('various-textobjs').cssSelector('inner')<CR>",
				mode = { 'o', 'x' },
				ft = { 'css', 'scss' },
			},
			{
				'ac',
				"<cmd>lua require('various-textobjs').cssSelector('outer')<CR>",
				mode = { 'o', 'x' },
				ft = { 'css', 'scss' },
			},

			{
				'ix',
				"<cmd>lua require('various-textobjs').htmlAttribute('inner')<CR>",
				mode = { 'o', 'x' },
				ft = { 'css', 'scss', 'html', 'xml', 'vue' },
			},
			{
				'ax',
				"<cmd>lua require('various-textobjs').htmlAttribute('outer')<CR>",
				mode = { 'o', 'x' },
				ft = { 'css', 'scss', 'html', 'xml', 'vue' },
			},

			{
				'iD',
				"<cmd>lua require('various-textobjs').doubleSquareBrackets('inner')<CR>",
				mode = { 'o', 'x' },
				ft = { 'lua', 'norg', 'sh', 'fish', 'zsh', 'bash', 'markdown' },
			},
			{
				'aD',
				"<cmd>lua require('various-textobjs').doubleSquareBrackets('outer')<CR>",
				mode = { 'o', 'x' },
				ft = { 'lua', 'norg', 'sh', 'fish', 'zsh', 'bash', 'markdown' },
			},

			{
				'iP',
				"<cmd>lua require('various-textobjs').shellPipe('inner')<CR>",
				mode = { 'o', 'x' },
				ft = { 'sh', 'bash', 'zsh', 'fish' },
			},
			{
				'aP',
				"<cmd>lua require('various-textobjs').shellPipe('outer')<CR>",
				mode = { 'o', 'x' },
				ft = { 'sh', 'bash', 'zsh', 'fish' },
			},
		},
		opts = { useDefaultKeymaps = false },
	},

	{
		-- 'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
		dir = vim.fn.stdpath 'config' .. '/plugins/lsp_lines.nvim',
		name = 'lsp_lines',
		dependencies = { 'nvim-lspconfig' },
		config = true,
	},

	-- {
	--   'dmmulroy/ts-error-translator.nvim',
	--   dependencies = { 'lsp_lines' },
	--   config = true,
	-- },
	-- {
	-- 	'code-biscuits/nvim-biscuits',
	-- 	dependencies = { 'treesitter' },
	-- 	event = { 'BufReadPost', 'BufNewFile' },
	-- 	opts = {
	-- 		default_config = {
	-- 			max_length = 12,
	-- 			min_distance = 5,
	-- 			prefix_string = ' 📎 ',
	-- 		},
	-- 		language_config = {
	-- 			html = { prefix_string = ' 🌐 ', },
	-- 			javascript = {
	-- 				prefix_string = ' ✨ ',
	-- 				max_length = 80,
	-- 			},
	-- 			python = {
	-- 				disabled = true,
	-- 			},
	-- 		},
	-- 	},
	-- },
}
