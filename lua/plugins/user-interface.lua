local color = require 'utils.color-utils'

-- Returns a string with a list of attached LSP clients, including
-- formatters and linters from null-ls, nvim-lint and formatter.nvim

local function get_attached_clients()
	local buf_clients = vim.lsp.get_clients { bufnr = 0 }
	if #buf_clients == 0 then
		return 'LSP Inactive'
	end

	local buf_ft = vim.bo.filetype
	local buf_client_names = {}

	-- add client
	for _, client in pairs(buf_clients) do
		if client.name ~= 'copilot' and client.name ~= 'null-ls' then
			table.insert(buf_client_names, client.name)
		end
	end

	-- Generally, you should use either null-ls or nvim-lint + formatter.nvim, not both.

	-- Add sources (from null-ls)
	-- null-ls registers each source as a separate attached client, so we need to filter for unique names down below.
	local null_ls_s, null_ls = pcall(require, 'null-ls')
	if null_ls_s then
		local sources = null_ls.get_sources()
		for _, source in ipairs(sources) do
			if source._validated then
				for ft_name, ft_active in pairs(source.filetypes) do
					if ft_name == buf_ft and ft_active then
						table.insert(buf_client_names, source.name)
					end
				end
			end
		end
	end

	-- Add linters (from nvim-lint)
	local lint_s, lint = pcall(require, 'lint')
	if lint_s then
		for ft_k, ft_v in pairs(lint.linters_by_ft) do
			if type(ft_v) == 'table' then
				for _, linter in ipairs(ft_v) do
					if buf_ft == ft_k then
						table.insert(buf_client_names, linter)
					end
				end
			elseif type(ft_v) == 'string' then
				if buf_ft == ft_k then
					table.insert(buf_client_names, ft_v)
				end
			end
		end
	end

	-- Add formatters (from formatter.nvim)
	local formatter_s, _ = pcall(require, 'formatter')
	if formatter_s then
		local formatter_util = require 'formatter.util'
		for _, formatter in ipairs(formatter_util.get_available_formatters_for_ft(buf_ft)) do
			if formatter then
				table.insert(buf_client_names, formatter)
			end
		end
	end

	-- This needs to be a string only table so we can use concat below
	local unique_client_names = {}
	for _, client_name_target in ipairs(buf_client_names) do
		local is_duplicate = false
		for _, client_name_compare in ipairs(unique_client_names) do
			if client_name_target == client_name_compare then
				is_duplicate = true
			end
		end
		if not is_duplicate then
			table.insert(unique_client_names, client_name_target)
		end
	end

	local client_names_str = table.concat(unique_client_names, ', ')
	local language_servers = string.format('[%s]', client_names_str)

	return language_servers
end

return {
	-- Catppuccin theme
	{
		'catppuccin/nvim',
		name = 'catppuccin',
		lazy = false,    -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins
		init = function()
			vim.cmd.colorscheme 'catppuccin'
		end,
		opts = {
			flavour = 'frappe',         -- latte, frappe, macchiato, mocha
			transparent_background = true,
			show_end_of_buffer = false, -- show the '~' characters after the end of buffers
			term_colors = true,
			dim_inactive = { enabled = false },
			integrations = {
				cmp = true,
				gitsigns = true,
				nvimtree = true,
				telescope = true,
				notify = true,
				mini = true,
				barbar = true,
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

			custom_highlights = color.customCatppuccinHighlight,
		},
	},

	{
		'lukas-reineke/headlines.nvim',
		event = 'BufRead',
		dependencies = 'nvim-treesitter/nvim-treesitter',
		opts = {
			markdown = {
				fat_headlines = true,
				fat_headline_upper_string = '▅',
				fat_headline_lower_string = '▀',
			},
		},
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
				-- anchor = 'NW',
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
				bottom_search = true,         -- use a classic bottom cmdline for search
				command_palette = true,       -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = true,            -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = true,        -- add a border to hover docs and signature help
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
						inactive = false,    -- when true, other windows will be fully dimmed (unless they contain the same buffer)
					},
					context = 10,          -- amount of lines we will try to show around the current line
					treesitter = true,     -- use treesitter when available for the filetype
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
				height = 1,   -- height of the Zen window
				-- by default, no options are changed for the Zen window
				-- uncomment any of the options below, or add other vim.wo options you want to apply
				options = {
					signcolumn = 'no',      -- disable signcolumn
					number = false,         -- disable number column
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
					ruler = false,                -- disables the ruler text in the cmd line area
					showcmd = false,              -- disables the command in the last line of the screen
				},
				twilight = { enabled = true },  -- enable to start Twilight when zen mode opens
				gitsigns = { enabled = false }, -- disables git signs
			},
		},
	},

	-- Scrollbar
	{
		'petertriho/nvim-scrollbar',
		event = { 'BufReadPre', 'BufNewFile' },
		opts = {
			show = true,
			show_in_active_only = true,
			set_highlights = true,
			folds = false,     -- handle folds, set to number to disable folds if no. of lines in buffer exceeds this
			max_lines = false, -- disables if no. of lines in buffer exceeds this
			handle = {
				text = ' ',
				color = nil,
				cterm = nil,
				highlight = 'CursorColumn',
				hide_if_all_visible = true, -- Hides handle if all lines are visible
			},
			marks = {
				Search = {
					text = { '-', '=' },
					priority = 0,
					color = nil,
					cterm = nil,
					highlight = 'Search',
				},
				Error = {
					text = { '-', '=' },
					priority = 1,
					color = nil,
					cterm = nil,
					highlight = 'DiagnosticVirtualTextError',
				},
				Warn = {
					text = { '-', '=' },
					priority = 2,
					color = nil,
					cterm = nil,
					highlight = 'DiagnosticVirtualTextWarn',
				},
				Info = {
					text = { '-', '=' },
					priority = 3,
					color = nil,
					cterm = nil,
					highlight = 'DiagnosticVirtualTextInfo',
				},
				Hint = {
					text = { '-', '=' },
					priority = 4,
					color = nil,
					cterm = nil,
					highlight = 'DiagnosticVirtualTextHint',
				},
				Misc = {
					text = { '-', '=' },
					priority = 5,
					color = nil,
					cterm = nil,
					highlight = 'Normal',
				},
			},
			excluded_buftypes = {
				'terminal',
				'NvimTree',
			},
			excluded_filetypes = {
				'prompt',
				'TelescopePrompt',
			},
			autocmd = {
				render = {
					'BufWinEnter',
					'TabEnter',
					'TermEnter',
					'WinEnter',
					'CmdwinLeave',
					'TextChanged',
					'VimResized',
					'WinScrolled',
				},
				clear = {
					'BufWinLeave',
					'TabLeave',
					'TermLeave',
					'WinLeave',
				},
			},
			handlers = {
				cursor = true,
				gitsigns = false,
				diagnostic = true,
				search = false, -- Requires hlslens to be loaded, will run require("scrollbar.handlers.search").setup() for you
			},
		},
	},

	-- Status and buffer bar
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		event = 'VeryLazy',
		config = function(_, opts)
			local attached_clients = {
				get_attached_clients,
				color = { gui = 'bold' },
			}

			require('lualine').setup {
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
						attached_clients,
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
		end,
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
			{ '<C-t>',     '<cmd>tabnew<cr>' },   -- New tab
			{ '<Leader>q', '<cmd>bdelete<cr>' },  -- Close the current buffer
			{ '<Leader>Q', '<cmd>bdelete!<cr>' }, -- Close the current buffer
			{ '<C-Tab>',   vim.cmd.tabnext },     -- Next tab
			{ '<C-S-Tab>', vim.cmd.tabprevious }, -- Previous tab
			{ '<Tab>',     vim.cmd.bnext },       -- Next tab
			{ '<S-Tab>',   vim.cmd.bprev },       -- Previous tab
		},
		cmd = { 'BufferLineCloseLeft', 'BufferLineCloseRight' },
		opts = {
			options = {
				right_mouse_command = nil,        -- can be a string | function | false, see "Mouse actions"
				left_mouse_command = 'buffer %d', -- can be a string | function, | false see "Mouse actions"
				middle_mouse_command = nil,       -- can be a string | function, | false see "Mouse actions"
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
			attach_navic = false,

			---whether to create winbar updater autocmd
			---@type boolean
			create_autocmd = false,
		},
		config = function(_, opts)
			require('barbecue').setup(opts)
			vim.api.nvim_create_autocmd({
				'WinResized',
				'BufWinEnter',
				'CursorHold',
				'InsertLeave',
			}, {
				group = vim.api.nvim_create_augroup('barbecue.updater', {}),
				callback = function()
					require('barbecue.ui').update()
				end,
			})
		end,
	},

	{
		'lukas-reineke/indent-blankline.nvim',
		enabled = false,
		main = 'ibl',
		event = { 'BufReadPost', 'BufNewFile' },
		opts = {
			indent = {
				highlight = {
					'IndentBlanklineIndent1',
					'IndentBlanklineIndent2',
					'IndentBlanklineIndent3',
					'IndentBlanklineIndent4',
					'IndentBlanklineIndent5',
					'IndentBlanklineIndent6',
				},

				char = '▏',
			},
		},
	},
}
