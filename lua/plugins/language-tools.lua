local lazy_load = require('utils').import.lazy_load
return {
	{
		'windwp/nvim-autopairs',
		event = 'InsertEnter',
		opts = {
			check_ts = true,
			ts_config = {
				javascript = { 'template_string' },
				typescript = { 'template_string' },
			},

			disable_filetype = { 'TelescopePrompt', 'spectre_panel' },
			disable_in_macro = true,        -- disable when recording or executing a macro
			disable_in_visualblock = false, -- disable when insert after visual block mode
			disable_in_replace_mode = true,
			ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
			enable_moveright = true,
			enable_afterquote = true,         -- add bracket pairs after quote
			enable_check_bracket_line = true, --- check bracket in same line
			enable_bracket_in_quote = true,   --
			enable_abbr = false,              -- trigger abbreviation
			break_undo = true,                -- switch for basic rule break undo sequence
			map_cr = true,
			map_bs = true,                    -- map the <BS> key
			map_c_h = false,                  -- Map the <C-h> key to delete a pair
			map_c_w = false,                  -- map <c-w> to delete a pair if possible

			fast_wrap = {
				map = '<M-e>',
				chars = { '{', '[', '(', '"', "'" },
				pattern = [=[[%'%"%>%]%)%}%,]]=],
				end_key = '$',
				before_key = 'h',
				after_key = 'l',
				cursor_pos_before = true,
				keys = 'qwertyuiopzxcvbnmasdfghjkl',
				manual_position = true,
				highlight = 'Search',
				highlight_grey = 'Comment',
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

			-- Autopairs
			'nvim-autopairs',
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
						mode = 'symbol',       -- show only symbol annotations
						maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
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
					{ name = 'nvim_lsp',                group_index = 1 },
					{ name = 'path',                    group_index = 1 },
					{ name = 'luasnip',                 max_item_count = 4, group_index = 2 },
					--{ name = "nvim_lua" },
					{ name = 'nvim_lsp_signature_help', group_index = 1 },
					--{ name = "buffer" },
				},

				preselect = cmp.PreselectMode.Item,
			}

			-- if not vim.g.autopair_confirm_attached then
			local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
			cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done { map_char = { tex = '' } })
			-- 	vim.g.autopair_confirm_attached = 1
			-- end

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
			signs = true,      -- show icons in the signs column
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
				multiline = true,                -- enable multine todo comments
				multiline_pattern = '^.',        -- lua pattern to match the next multiline from the start of the matched keyword
				multiline_context = 10,          -- extra lines that will be re-evaluated when changing a line
				before = '',                     -- "fg" or "bg" or empty
				keyword = 'wide',                -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
				after = 'fg',                    -- "fg" or "bg" or empty
				pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
				comments_only = true,            -- uses treesitter to match keywords in comments only
				max_line_len = 400,              -- ignore lines longer than this
				exclude = {},                    -- list of file types to exclude highlighting
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
				desc = 'Generate annotating documentation',
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

	-- {
	-- 	'vuki656/package-info.nvim',
	-- 	dependencies = { 'MunifTanjim/nui.nvim' },
	-- 	ft = { 'json' },

	-- 	keys = {
	-- 		-- -- Show dependency versions
	-- 		-- vim.keymap.set({ "n" }, "<LEADER>ns", require("package-info").show, { silent = true, noremap = true })

	-- 		-- -- Hide dependency versions
	-- 		-- vim.keymap.set({ "n" }, "<LEADER>nc", require("package-info").hide, { silent = true, noremap = true })

	-- 		-- -- Toggle dependency versions
	-- 		-- vim.keymap.set({ "n" }, "<LEADER>nt", require("package-info").toggle, { silent = true, noremap = true })

	-- 		-- -- Update dependency on the line
	-- 		-- vim.keymap.set({ "n" }, "<LEADER>nu", require("package-info").update, { silent = true, noremap = true })

	-- 		-- -- Delete dependency on the line
	-- 		-- vim.keymap.set({ "n" }, "<LEADER>nd", require("package-info").delete, { silent = true, noremap = true })

	-- 		-- -- Install a new dependency
	-- 		-- vim.keymap.set({ "n" }, "<LEADER>ni", require("package-info").install, { silent = true, noremap = true })

	-- 		-- -- Install a different dependency version
	-- 		-- vim.keymap.set({ "n" }, "<LEADER>np", require("package-info").change_version, { silent = true, noremap = true })
	-- 	},

	-- 	opts = {
	-- 		colors = {
	-- 			up_to_date = '#3C4048', -- Text color for up to date dependency virtual text
	-- 			outdated = '#d19a66',   -- Text color for outdated dependency virtual text
	-- 		},
	-- 		icons = {
	-- 			enable = true, -- Whether to display icons
	-- 			style = {
	-- 				up_to_date = '|  ', -- Icon for up to date dependencies
	-- 				outdated = '|  ', -- Icon for outdated dependencies
	-- 			},
	-- 		},
	-- 		autostart = true,               -- Whether to autostart when `package.json` is opened
	-- 		hide_up_to_date = false,        -- It hides up to date versions when displaying virtual text
	-- 		hide_unstable_versions = false, -- It hides unstable versions from version list e.g next-11.1.3-canary3
	-- 		-- Can be `npm`, `yarn`, or `pnpm`. Used for `delete`, `install` etc...
	-- 		-- The plugin will try to auto-detect the package manager based on
	-- 		-- `yarn.lock` or `package-lock.json`. If none are found it will use the
	-- 		-- provided one, if nothing is provided it will use `yarn`
	-- 		package_manager = 'pnpm',
	-- 	},
	-- },

	{
		'stevearc/aerial.nvim',
		dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
		cmd = { 'AerialToggle' },
		keys = { { '<leader>la', '<cmd>AerialToggle!<CR>', mode = { 'n' }, desc = 'Show Aerial sidebar' } },
		opts = {
			-- Priority list of preferred backends for aerial.
			-- This can be a filetype map (see :help aerial-filetype-map)
			-- backends = { 'treesitter', 'lsp', 'markdown', 'asciidoc', 'man' },
			backends = {
				['_'] = { 'treesitter', 'lsp', 'markdown', 'asciidoc', 'man' },
				json = { 'lsp', 'treesitter' },
			},

			layout = {
				-- These control the width of the aerial window.
				-- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
				-- min_width and max_width can be a list of mixed types.
				-- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
				-- max_width = { 40, 0.2 },
				-- width = nil,
				-- min_width = 10,

				-- key-value pairs of window-local options for aerial window (e.g. winhl)
				-- win_opts = {},

				-- Determines the default direction to open the aerial window. The 'prefer'
				-- options will open the window in the other direction *if* there is a
				-- different buffer in the way of the preferred direction
				-- Enum: prefer_right, prefer_left, right, left, float
				default_direction = 'prefer_left',

				-- Determines where the aerial window will be opened
				--   edge   - open aerial at the far right/left of the editor
				--   window - open aerial to the right/left of the current window
				placement = 'window',

				-- When the symbols change, resize the aerial window (within min/max constraints) to fit
				resize_to_content = true,

				-- Preserve window size equality with (:help CTRL-W_=)
				preserve_equality = false,
			},

			-- Determines how the aerial window decides which buffer to display symbols for
			--   window - aerial window will display symbols for the buffer in the window from which it was opened
			--   global - aerial window will display symbols for the current window
			-- attach_mode = 'window',

			-- List of enum values that configure when to auto-close the aerial window
			--   unfocus       - close aerial when you leave the original source window
			--   switch_buffer - close aerial when you change buffers in the source window
			--   unsupported   - close aerial when attaching to a buffer that has no symbol source
			-- close_automatic_events = {},

			-- Keymaps in aerial window. Can be any value that `vim.keymap.set` accepts OR a table of keymap
			-- options with a `callback` (e.g. { callback = function() ... end, desc = "", nowait = true })
			-- Additionally, if it is a string that matches "actions.<name>",
			-- it will use the mapping at require("aerial.actions").<name>
			-- Set to `false` to remove a keymap
			keymaps = {
				['?'] = 'actions.show_help',
				['g?'] = 'actions.show_help',
				['<CR>'] = 'actions.jump',
				['<2-LeftMouse>'] = 'actions.jump',
				['<C-v>'] = 'actions.jump_vsplit',
				['<C-s>'] = 'actions.jump_split',
				['p'] = 'actions.scroll',
				['<C-j>'] = 'actions.down_and_scroll',
				['<C-k>'] = 'actions.up_and_scroll',
				['{'] = 'actions.prev',
				['}'] = 'actions.next',
				['[['] = 'actions.prev_up',
				[']]'] = 'actions.next_up',
				['K'] = 'actions.prev_up',
				['J'] = 'actions.next_up',
				['q'] = 'actions.close',
				['o'] = 'actions.tree_toggle',
				['za'] = 'actions.tree_toggle',
				['O'] = 'actions.tree_toggle_recursive',
				['zA'] = 'actions.tree_toggle_recursive',
				['l'] = 'actions.tree_open',
				['zo'] = 'actions.tree_open',
				[')'] = 'actions.tree_open',
				['L'] = 'actions.tree_open_recursive',
				['zO'] = 'actions.tree_open_recursive',
				['h'] = 'actions.tree_close',
				['zc'] = 'actions.tree_close',
				['('] = 'actions.tree_close',
				['H'] = 'actions.tree_close_recursive',
				['zC'] = 'actions.tree_close_recursive',
				['zr'] = 'actions.tree_increase_fold_level',
				['zR'] = 'actions.tree_open_all',
				['zm'] = 'actions.tree_decrease_fold_level',
				['zM'] = 'actions.tree_close_all',
				['zx'] = 'actions.tree_sync_folds',
				['zX'] = 'actions.tree_sync_folds',
			},

			-- When true, don't load aerial until a command or function is called
			-- Defaults to true, unless `on_attach` is provided, then it defaults to false
			-- lazy_load = true,

			-- Disable aerial on files with this many lines
			-- disable_max_lines = 10000,

			-- Disable aerial on files this size or larger (in bytes)
			-- disable_max_size = 2000000, -- Default 2MB

			-- A list of all symbols to display. Set to false to display all symbols.
			-- This can be a filetype map (see :help aerial-filetype-map)
			-- To see all available values, see :help SymbolKind
			-- filter_kind = {
			--   'Class',
			--   'Constructor',
			--   'Enum',
			--   'Function',
			--   'Interface',
			--   'Module',
			--   'Method',
			--   'Struct',
			-- },
			filter_kind = {
				['_'] = {
					'Class',
					'Constructor',
					'Enum',
					'Function',
					'Interface',
					'Module',
					'Method',
					'Struct',
				},

				json = {
					'Array',
					'Class',
					'Constructor',
					'Enum',
					'Function',
					'Interface',
					'Module',
					'Method',
					'Struct',
				},

				-- {
				-- 	'Array',
				-- 	'Boolean',
				-- 	'Class',
				-- 	'Constant',
				-- 	'Constructor',
				-- 	'Enum',
				-- 	'EnumMember',
				-- 	'Event',
				-- 	'Field',
				-- 	'File',
				-- 	'Function',
				-- 	'Interface',
				-- 	'Key',
				-- 	'Method',
				-- 	'Module',
				-- 	'Namespace',
				-- 	'Null',
				-- 	'Number',
				-- 	'Object',
				-- 	'Operator',
				-- 	'Package',
				-- 	'Property',
				-- 	'String',
				-- 	'Struct',
				-- 	'TypeParameter',
				-- 	'Variable',
				-- }
			},

			-- Determines line highlighting mode when multiple splits are visible.
			-- split_width   Each open window will have its cursor location marked in the
			--               aerial buffer. Each line will only be partially highlighted
			--               to indicate which window is at that location.
			-- full_width    Each open window will have its cursor location marked as a
			--               full-width highlight in the aerial buffer.
			-- last          Only the most-recently focused window will have its location
			--               marked in the aerial buffer.
			-- none          Do not show the cursor locations in the aerial window.
			-- highlight_mode = 'split_width',

			-- Highlight the closest symbol if the cursor is not exactly on one.
			-- highlight_closest = true,

			-- Highlight the symbol in the source buffer when cursor is in the aerial win
			highlight_on_hover = true,

			-- When jumping to a symbol, highlight the line for this many ms.
			-- Set to false to disable
			highlight_on_jump = 300,

			-- Jump to symbol in source window when the cursor moves
			autojump = false,

			-- Define symbol icons. You can also specify "<Symbol>Collapsed" to change the
			-- icon when the tree is collapsed at that symbol, or "Collapsed" to specify a
			-- default collapsed icon. The default icon set is determined by the
			-- "nerd_font" option below.
			-- If you have lspkind-nvim installed, it will be the default icon set.
			-- This can be a filetype map (see :help aerial-filetype-map)
			-- icons = {},

			-- Control which windows and buffers aerial should ignore.
			-- Aerial will not open when these are focused, and existing aerial windows will not be updated
			-- ignore = {
			--   -- Ignore unlisted buffers. See :help buflisted
			--   unlisted_buffers = false,

			--   -- Ignore diff windows (setting to false will allow aerial in diff windows)
			--   diff_windows = true,

			--   -- List of filetypes to ignore.
			--   filetypes = {},

			--   -- Ignored buftypes.
			--   -- Can be one of the following:
			--   -- false or nil - No buftypes are ignored.
			--   -- "special"    - All buffers other than normal, help and man page buffers are ignored.
			--   -- table        - A list of buftypes to ignore. See :help buftype for the
			--   --                possible values.
			--   -- function     - A function that returns true if the buffer should be
			--   --                ignored or false if it should not be ignored.
			--   --                Takes two arguments, `bufnr` and `buftype`.
			--   buftypes = 'special',

			--   -- Ignored wintypes.
			--   -- Can be one of the following:
			--   -- false or nil - No wintypes are ignored.
			--   -- "special"    - All windows other than normal windows are ignored.
			--   -- table        - A list of wintypes to ignore. See :help win_gettype() for the
			--   --                possible values.
			--   -- function     - A function that returns true if the window should be
			--   --                ignored or false if it should not be ignored.
			--   --                Takes two arguments, `winid` and `wintype`.
			--   wintypes = 'special',
			-- },

			-- Use symbol tree for folding. Set to true or false to enable/disable
			-- Set to "auto" to manage folds if your previous foldmethod was 'manual'
			-- This can be a filetype map (see :help aerial-filetype-map)
			-- manage_folds = false,
			manage_folds = true,

			-- When you fold code with za, zo, or zc, update the aerial tree as well.
			-- Only works when manage_folds = true
			link_folds_to_tree = true,

			-- Fold code when you open/collapse symbols in the tree.
			-- Only works when manage_folds = true
			link_tree_to_folds = true,

			-- Set default symbol icons to use patched font icons (see https://www.nerdfonts.com/)
			-- "auto" will set it to true if nvim-web-devicons or lspkind-nvim is installed.
			-- nerd_font = 'auto',

			-- Call this function when aerial attaches to a buffer.
			-- on_attach = function(bufnr)
			-- Jump forwards/backwards with '{' and '}'
			-- vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', { buffer = bufnr })
			-- vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', { buffer = bufnr })
			-- end,

			-- Call this function when aerial first sets symbols on a buffer.
			-- on_first_symbols = function(bufnr) end,

			-- Automatically open aerial when entering supported buffers.
			-- This can be a function (see :help aerial-open-automatic)
			-- open_automatic = false,

			-- Run this command after jumping to a symbol (false will disable)
			-- post_jump_cmd = 'normal! zz',

			-- Invoked after each symbol is parsed, can be used to modify the parsed item,
			-- or to filter it by returning false.
			--
			-- bufnr: a neovim buffer number
			-- item: of type aerial.Symbol
			-- ctx: a record containing the following fields:
			--   * backend_name: treesitter, lsp, man...
			--   * lang: info about the language
			--   * symbols?: specific to the lsp backend
			--   * symbol?: specific to the lsp backend
			--   * syntax_tree?: specific to the treesitter backend
			--   * match?: specific to the treesitter backend, TS query match
			post_parse_symbol = function(bufnr, item, ctx, opts)
				if item.kind == 'Array' then
					local child_count = vim.tbl_count(ctx.symbol.children);
					item.name = item.name .. "[" .. child_count .. "]";
				end
			end,

			-- Invoked after all symbols have been parsed and post-processed,
			-- allows to modify the symbol structure before final display
			--
			-- bufnr: a neovim buffer number
			-- items: a collection of aerial.Symbol items, organized in a tree,
			--        with 'parent' and 'children' fields
			-- ctx: a record containing the following fields:
			--   * backend_name: treesitter, lsp, man...
			--   * lang: info about the language
			--   * symbols?: specific to the lsp backend
			--   * syntax_tree?: specific to the treesitter backend
			-- post_add_all_symbols = function(bufnr, items, ctx)
			--   return items
			-- end,

			-- When true, aerial will automatically close after jumping to a symbol
			-- close_on_select = false,

			-- The autocmds that trigger symbols update (not used for LSP backend)
			-- update_events = 'TextChanged,InsertLeave',

			-- Show box drawing characters for the tree hierarchy
			show_guides = true,

			-- Customize the characters used when show_guides = true
			-- guides = {
			--   -- When the child item has a sibling below it
			--   mid_item = '├─',
			--   -- When the child item is the last in the list
			--   last_item = '└─',
			--   -- When there are nested child guides to the right
			--   nested_top = '│ ',
			--   -- Raw indentation
			--   whitespace = '  ',
			-- },

			-- Set this function to override the highlight groups for certain symbols
			-- get_highlight = function(symbol, is_icon, is_collapsed)
			--   -- return "MyHighlight" .. symbol.kind
			-- end,

			-- Options for opening aerial in a floating win
			-- float = {
			--   -- Controls border appearance. Passed to nvim_open_win
			--   border = 'rounded',

			--   -- Determines location of floating window
			--   --   cursor - Opens float on top of the cursor
			--   --   editor - Opens float centered in the editor
			--   --   win    - Opens float centered in the window
			--   relative = 'cursor',

			--   -- These control the height of the floating window.
			--   -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
			--   -- min_height and max_height can be a list of mixed types.
			--   -- min_height = {8, 0.1} means "the greater of 8 rows or 10% of total"
			--   max_height = 0.9,
			--   height = nil,
			--   min_height = { 8, 0.1 },

			--   override = function(conf, source_winid)
			--     -- This is the config that will be passed to nvim_open_win.
			--     -- Change values here to customize the layout
			--     return conf
			--   end,
			-- },

			-- Options for the floating nav windows
			-- nav = {
			--   border = 'rounded',
			--   max_height = 0.9,
			--   min_height = { 10, 0.1 },
			--   max_width = 0.5,
			--   min_width = { 0.2, 20 },
			--   win_opts = {
			--     cursorline = true,
			--     winblend = 10,
			--   },
			--   -- Jump to symbol in source window when the cursor moves
			--   autojump = false,
			--   -- Show a preview of the code in the right column, when there are no child symbols
			--   preview = false,
			--   -- Keymaps in the nav window
			--   keymaps = {
			--     ['<CR>'] = 'actions.jump',
			--     ['<2-LeftMouse>'] = 'actions.jump',
			--     ['<C-v>'] = 'actions.jump_vsplit',
			--     ['<C-s>'] = 'actions.jump_split',
			--     ['h'] = 'actions.left',
			--     ['l'] = 'actions.right',
			--     ['<C-c>'] = 'actions.close',
			--   },
			-- },

			lsp = {
				-- If true, fetch document symbols when LSP diagnostics update.
				diagnostics_trigger_update = true,

				-- Set to false to not update the symbols when there are LSP errors
				update_when_errors = true,

				-- How long to wait (in ms) after a buffer change before updating
				-- Only used when diagnostics_trigger_update = false
				-- update_delay = 300,

				-- -- Map of LSP client name to priority. Default value is 10.
				-- -- Clients with higher (larger) priority will be used before those with lower priority.
				-- -- Set to -1 to never use the client.
				-- priority = {
				--   -- pyright = 10,
				-- },
			},

			-- treesitter = {
			--   -- How long to wait (in ms) after a buffer change before updating
			--   update_delay = 300,
			-- },

			-- markdown = {
			--   -- How long to wait (in ms) after a buffer change before updating
			--   update_delay = 300,
			-- },

			-- asciidoc = {
			--   -- How long to wait (in ms) after a buffer change before updating
			--   update_delay = 300,
			-- },

			-- man = {
			--   -- How long to wait (in ms) after a buffer change before updating
			--   update_delay = 300,
			-- },
		},
		-- config = function(_, opts)
		-- 	require('aerial').setup(vim.tbl_deep_extend('force', opts, {
		-- 		post_parse_symbol = function(bufnr, item, ctx)
		-- 			if opts.post_parse_symbol ~= nil then
		-- 				return opts.post_parse_symbol(bufnr, item, ctx, opts)
		-- 			else
		-- 				return true
		-- 			end
		-- 		end,
		-- 	}))
		-- end,
	},
}
