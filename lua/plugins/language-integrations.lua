return {
	require 'plugins.lsp.lsp-servers',
	require 'plugins.lsp.formatting',
	require 'plugins.lsp.dap',
	require 'plugins.lsp.completion',
	require 'plugins.lsp.linters',
	require 'plugins.lsp.off-spec',
	require 'plugins.lsp.treesitter'
}


	-- {
	-- 	'jose-elias-alvarez/null-ls.nvim',
	-- 	event = { 'BufReadPost', 'BufNewFile' },
	-- 	enabled = false,
	-- 	dependencies = {
	-- 		'williamboman/mason.nvim',
	-- 		{
	-- 			'jayp0521/mason-null-ls.nvim',
	-- 			opts = {
	-- 				automatic_installation = true,
	-- 				automatic_setup = true,
	-- 			}
	-- 		},
	-- 		-- 'jose-elias-alvarez/typescript.nvim',
	-- 	},

	-- 	opts = function()
	-- 		local nls = require 'null-ls'

	-- 		-- The null-ls sources to use
	-- 		return {
	-- 			root_dir = require('null-ls.utils').root_pattern('.null-ls-root', '.neoconf.json', 'Makefile', '.git'),
	-- 			sources = {
	-- 				-- Code actions
	-- 				nls.builtins.code_actions.gitsigns,

	-- 				-- Diagnostics
	-- 				nls.builtins.diagnostics.cmake_lint,
	-- 				nls.builtins.diagnostics.commitlint,
	-- 				nls.builtins.diagnostics.cpplint,
	-- 				nls.builtins.diagnostics.gitlint,
	-- 				nls.builtins.diagnostics.hadolint,

	-- 				-- Completion
	-- 				nls.builtins.completion.tags,

	-- 				-- Formatting
	-- 				nls.builtins.formatting.prettier.with {
	-- 					filetypes = {
	-- 						'css',
	-- 						'graphql',
	-- 						'html',
	-- 						'javascript',
	-- 						'javascriptreact',
	-- 						'json',
	-- 						'less',
	-- 						'markdown',
	-- 						'scss',
	-- 						'typescript',
	-- 						'typescriptreact',
	-- 						'yaml',
	-- 					},
	-- 					timeout = 5000,
	-- 				},
	-- 				nls.builtins.formatting.stylua,
	-- 				nls.builtins.formatting.clang_format,
	-- 				nls.builtins.formatting.black,
	-- 				nls.builtins.formatting.isort,
	-- 				nls.builtins.formatting.rustfmt,
	-- 			},
	-- 		}
	-- 	end,
	-- },

	-- {
	-- 	'junnplus/lsp-setup.nvim',
	-- 	event = { 'BufReadPost', 'BufNewFile' },
	-- 	dependencies = {
	-- 		'neovim/nvim-lspconfig',
	-- 		{ 'folke/neoconf.nvim', cmd = 'Neoconf',                                lazy = false, opts = {} },
	-- 		{ 'folke/neodev.nvim',  opts = { experimental = { pathStrict = true } } },

	-- 		'williamboman/mason.nvim',
	-- 		'williamboman/mason-lspconfig.nvim',
	-- 		'Issafalcon/lsp-overloads.nvim',
	-- 		-- 'lvimuser/lsp-inlayhints.nvim',
	-- 		{
	-- 			'marilari88/twoslash-queries.nvim',
	-- 			opts = {
	-- 				multi_line = true, -- to print types in multi line mode
	-- 				is_enabled = true, -- to keep enabled at startup
	-- 			},
	-- 		},
	-- 		'joeveiga/ng.nvim',
	-- 	},

	-- 	opts = {
	-- 		default_mappings = false,
	-- 		mappings = {
	-- 			['K'] = lazy_load('noice.lsp', 'hover'),
	-- 			['<leader>rn'] = vim.lsp.buf.rename,
	-- 			['<C-space>'] = vim.lsp.buf.code_action,
	-- 		},

	-- 		servers = {
	-- 			-- Shell languages
	-- 			bashls = {},

	-- 			-- Editor specific features
	-- 			lua_ls = {
	-- 				settings = {
	-- 					Lua = {
	-- 						workspace = { checkThirdParty = false },
	-- 						hint = {
	-- 							enable = true,
	-- 							arrayIndex = 'Auto',
	-- 							await = true,
	-- 							paramName = 'All',
	-- 							paramType = true,
	-- 							semicolon = 'SameLine',
	-- 							setType = false,
	-- 						},
	-- 					},
	-- 				},
	-- 			},
	-- 			vimls = {},

	-- 			-- System languages
	-- 			dockerls = {},
	-- 			denols = {
	-- 				autostart = false,
	-- 				settings = { cmd_env = { NO_COLOR = false } },
	-- 			},
	-- 			yamlls = {
	-- 				settings = {
	-- 					yaml = {
	-- 						-- FIX mapKeyOrder warning
	-- 						keyOrdering = false,
	-- 					},
	-- 				},
	-- 			},
	-- 			rust_analyzer = {},
	-- 			pyright = {},

	-- 			-- Web languages
	-- 			angularls = {},
	-- 			cssls = {},
	-- 			html = {},
	-- 			jsonls = {},
	-- 			cssmodules_ls = {},
	-- 			emmet_ls = {},
	-- 			tsserver = {},
	-- 		},
	-- 		capabilities = vim.lsp.protocol.make_client_capabilities(),
	-- 		on_attach = function(client, bufnr)
	-- 			if client.name == 'tsserver' then
	-- 				with('twoslash-queries', function(twoslash)
	-- 					twoslash.attach(client, bufnr)
	-- 				end)
	-- 			end

	-- 			-- Add the autocommands for highlighting under the cursor
	-- 			if client.supports_method 'textDocument/documentHighlight' then
	-- 				vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' },
	-- 					{ callback = vim.lsp.buf.document_highlight, buffer = bufnr })
	-- 				vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' },
	-- 					{ callback = vim.lsp.buf.clear_references, buffer = bufnr })
	-- 			end

	-- 			-- Add the autocommands for formatting on save
	-- 			if client.supports_method 'textDocument/formatting' then
	-- 				local lspFormatAUGroup = vim.api.nvim_create_augroup('LspFormatting', {})
	-- 				vim.api.nvim_clear_autocmds { group = lspFormatAUGroup, buffer = bufnr }
	-- 				vim.api.nvim_create_autocmd('BufWritePre', {
	-- 					group = lspFormatAUGroup,
	-- 					buffer = bufnr,
	-- 					callback = function()
	-- 						require('utils.format').format_buffer(bufnr)
	-- 					end,
	-- 				})
	-- 			end
	-- 		end,
	-- 	},

	-- 	-- config = function(_, opts)
	-- 	--   vim.lsp.set_log_level 'debug'
	-- 	--   require('lsp-setup').setup(opts)
	-- 	-- end,
	-- },
