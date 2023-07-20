local with = require('utils.import-utils').with
local lazy_load = require 'utils.import-utils'.lazy_load
local mapkeys = require 'plugins.lsp.utils.lsp'.mapkeys

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
		['<leader>rn'] = vim.lsp.buf.rename,
		['<leader>p'] = vim.lsp.buf.format,
		-- ['<leader>ldc'] = vim.lsp.buf.declaration,

		['<A-k>'] = { mode = { 'n', 'i' }, action = vim.lsp.buf.signature_help },
		['<C-x>'] = { mode = { 'n', 'i' }, action = vim.lsp.buf.code_action },
	}
}

-- The LSP servers we want to use.
-- These can be auto-installed by mason-lspconfig if they aren't yet available,
-- and the config can be overridden by adding one of these keys into the config
-- table below. Otherwise, an empty object is passed to the setup function.
lsp.servers = { 'bashls', 'vimls', 'lua_ls', 'denols', 'yamlls', 'dockerls', 'rust_analyzer', 'pyright', 'angularls',
	'cssls', 'html', 'jsonls', 'cssmodules_ls', 'emmet_ls', 'tsserver', 'efm' }

-- Custom overrides for specific clients.
-- All other "unconfigured" servers are just
-- set up with the default configurations.
lsp.config = {
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
	['tsserver'] = {
		on_attach = function(client, bufnr)
			with('twoslash-queries', function(twoslash)
				twoslash.attach(client, bufnr)
			end)
		end
	},
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
		vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' },
			{ callback = vim.lsp.buf.document_highlight, buffer = bufnr })
		vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' },
			{ callback = vim.lsp.buf.clear_references, buffer = bufnr })
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
		end
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
		lazy = false,
		opts = {}
	},

	{
		'folke/neodev.nvim',
		opts = { experimental = { pathStrict = true } },
		ft = { 'lua' }
	},

	-- Make everything just a bit friendlier to work with.
	{ 'williamboman/mason.nvim', opts = {}, build = ":MasonUpdate", lazy = true },
	{
		'williamboman/mason-lspconfig.nvim',
		opts = { automatic_installation = true, handlers = { lsp.configure } },
		dependencies = { 'williamboman/mason.nvim' },
		lazy = true
	},

	{
		'neovim/nvim-lspconfig',
		dependencies = {
			'folke/neoconf.nvim',
			'williamboman/mason-lspconfig.nvim',

			-- Some nice-to-haves with the language.
			{
				'marilari88/twoslash-queries.nvim',
				opts = {
					multi_line = true, -- to print types in multi line mode
					is_enabled = true, -- to keep enabled at startup
				},
			},
		},
		config = lsp.setup_servers
	}
}
