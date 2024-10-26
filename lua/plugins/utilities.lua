local lazy_load = require('utils').import.lazy_load
local function telescope_extension(method, opts)
	return function()
		require('telescope').extensions[method][method](opts)
	end
end

return {
	-- Swap buffers with each other
	{
		'caenrique/swap-buffers.nvim',
		keys = {
			{ '<C-w><C-h>', lazy_load { 'swap-buffers', 'swap-buffers', 'h' } },
			{ '<C-w><C-j>', lazy_load { 'swap-buffers', 'swap-buffers', 'j' } },
			{ '<C-w><C-k>', lazy_load { 'swap-buffers', 'swap-buffers', 'k' } },
			{ '<C-w><C-l>', lazy_load { 'swap-buffers', 'swap-buffers', 'l' } },
		},
	},

	-- Markdown preview and rendering
	{ 'ellisonleao/glow.nvim', config = true, cmd = 'Glow' },

	-- Save code to a pretty screenshot!
	{
		'narutoxy/silicon.lua',
		dev = true,
		keys = {
			{
				'<Leader>bs',
				lazy_load { 'silicon', 'visualise_api' },
				mode = { 'v' },
				desc = 'Generate image of lines in a visual selection',
			},
			{
				'<Leader>bc',
				lazy_load { 'silicon', 'visualise_api', { to_clip = true } },
				mode = { 'v' },
				desc = 'Generate image of lines in a visual selection, copied to the clipboard',
			},
			{
				'<Leader>bb',
				lazy_load { 'silicon', 'visualise_api', { show_buf = true } },
				mode = { 'v', 'n' },
				desc = 'Generate image of a whole buffer, with lines in a visual selection highlighted',
			},
			{
				'<Leader>bv',
				lazy_load { 'silicon', 'visualise_api', { to_clip = true, visible = true } },
				mode = { 'n', 'v' },
				desc = 'Generate visible portion of a buffer',
			},
		},
		dependencies = { 'nvim-lua/plenary.nvim' },
		opts = {
			theme = 'auto',
			-- auto generate file name based on time (absolute or relative to cwd)
			output = 'SILICON_${year}-${month}-${date}_${time}.png',
			roundCorner = true,
			windowControls = true,
			windowTitle = function()
				return vim.fn.expand '%'
			end,
			lineNumber = false,
			font = 'JetBrainsMono Nerd Font',
			lineOffset = 1, -- from where to start line number
			linePad = 2,    -- padding between lines
			padHoriz = 30,  -- Horizontal padding
			padVert = 40,   -- vertical padding
			shadowBlurRadius = 10,
			shadowColor = '#555555',
			shadowOffsetX = 8,
			shadowOffsetY = 8,
			gobble = true,
			debug = false,
		},
	},

	-- Allows the windows to be shifted with ease.
	{
		'sindrets/winshift.nvim',
		keys = {
			{
				'<leader>sw',
				function()
					require('winshift').cmd_winshift()
				end,
			},
			{
				'<leader>ss',
				function()
					require('winshift').cmd_winshift 'swap'
				end,
			},
		},
	},

	{
		'tpope/vim-fugitive',
		event = 'VeryLazy',
		keys = {
			{
				'<leader>gg',
				'<cmd>Git commit<cr>',
				desc = 'Commit currently staged files',
			},
		},
	},

	-- Diagnostics that are pretty
	{
		'folke/trouble.nvim',
		cmd = 'Trouble',
		keys = {
			{
				'<leader>xx',
				'<cmd>Trouble diagnostics toggle<cr>',
				desc = 'Diagnostics (Trouble)',
			},
			{
				'<leader>xX',
				'<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
				desc = 'Buffer Diagnostics (Trouble)',
			},
			{
				'<leader>cs',
				'<cmd>Trouble symbols toggle focus=false<cr>',
				desc = 'Symbols (Trouble)',
			},
			{
				'<leader>cl',
				'<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
				desc = 'LSP Definitions / references / ... (Trouble)',
			},
			{
				'<leader>xL',
				'<cmd>Trouble loclist toggle<cr>',
				desc = 'Location List (Trouble)',
			},
			{
				'<leader>xQ',
				'<cmd>Trouble qflist toggle<cr>',
				desc = 'Quickfix List (Trouble)',
			},
		},
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		opts = {
			-- position = 'bottom', -- position of the list can be: bottom, top, left, right
			-- height = 10, -- height of the trouble list when position is top or bottom
			-- width = 50, -- width of the list when position is left or right
			-- icons = true, -- use devicons for filenames
			-- mode = 'document_diagnostics', -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
			-- fold_open = '', -- icon used for open folds
			-- fold_closed = '', -- icon used for closed folds
			-- group = true, -- group results by file
			-- padding = true, -- add an extra new line on top of the list
			-- indent_lines = true, -- add an indent guide below the fold icons
			-- auto_open = false, -- automatically open the list when you have diagnostics
			-- auto_close = false, -- automatically close the list when you have no diagnostics
			-- auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
			-- auto_fold = false, -- automatically fold a file trouble list at creation
		},
	},

	{
		'stevearc/oil.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		opts = {
			-- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
			-- Set to false if you still want to use netrw.
			default_file_explorer = false,
			-- Id is automatically added at the beginning, and name at the end
			-- See :help oil-columns
			columns = {
				'icon',
				-- "permissions",
				-- "size",
				-- "mtime",
			},
			-- Buffer-local options to use for oil buffers
			buf_options = {
				buflisted = false,
				bufhidden = 'hide',
			},
			-- Window-local options to use for oil buffers
			win_options = {
				wrap = false,
				signcolumn = 'no',
				cursorcolumn = false,
				foldcolumn = '0',
				spell = false,
				list = false,
				conceallevel = 3,
				concealcursor = 'nvic',
			},
			-- Send deleted files to the trash instead of permanently deleting them (:help oil-trash)
			delete_to_trash = false,
			-- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
			skip_confirm_for_simple_edits = false,
			-- Selecting a new/moved/renamed file or directory will prompt you to save changes first
			-- (:help prompt_save_on_select_new_entry)
			prompt_save_on_select_new_entry = true,
			-- Oil will automatically delete hidden buffers after this delay
			-- You can set the delay to false to disable cleanup entirely
			-- Note that the cleanup process only starts when none of the oil buffers are currently displayed
			cleanup_delay_ms = 2000,
			lsp_file_methods = {
				-- Time to wait for LSP file operations to complete before skipping
				timeout_ms = 1000,
				-- Set to true to autosave buffers that are updated with LSP willRenameFiles
				-- Set to "unmodified" to only save unmodified buffers
				autosave_changes = false,
			},
			-- Constrain the cursor to the editable parts of the oil buffer
			-- Set to `false` to disable, or "name" to keep it on the file names
			constrain_cursor = 'editable',
			-- Set to true to watch the filesystem for changes and reload oil
			experimental_watch_for_changes = false,
			-- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
			-- options with a `callback` (e.g. { callback = function() ... end, desc = "", mode = "n" })
			-- Additionally, if it is a string that matches "actions.<name>",
			-- it will use the mapping at require("oil.actions").<name>
			-- Set to `false` to remove a keymap
			-- See :help oil-actions for a list of all available actions
			keymaps = {
				['g?'] = 'actions.show_help',
				['<CR>'] = 'actions.select',
				['<C-s>'] = 'actions.select_vsplit',
				['<C-h>'] = 'actions.select_split',
				['<C-t>'] = 'actions.select_tab',
				['<C-p>'] = 'actions.preview',
				['<C-c>'] = 'actions.close',
				['<C-l>'] = 'actions.refresh',
				['-'] = 'actions.parent',
				['_'] = 'actions.open_cwd',
				['`'] = 'actions.cd',
				['~'] = 'actions.tcd',
				['gs'] = 'actions.change_sort',
				['gx'] = 'actions.open_external',
				['g.'] = 'actions.toggle_hidden',
				['g\\'] = 'actions.toggle_trash',
			},
			-- Configuration for the floating keymaps help window
			keymaps_help = { border = 'rounded' },
			-- Set to false to disable all of the above keymaps
			use_default_keymaps = true,
			view_options = {
				-- Show files and directories that start with "."
				show_hidden = false,
				-- This function defines what is considered a "hidden" file
				is_hidden_file = function(name, bufnr)
					return vim.startswith(name, '.')
				end,
				-- This function defines what will never be shown, even when `show_hidden` is set
				is_always_hidden = function(name, bufnr)
					return false
				end,
				-- Sort file names in a more intuitive order for humans. Is less performant,
				-- so you may want to set to false if you work with large directories.
				natural_order = true,
				sort = {
					-- sort order can be "asc" or "desc"
					-- see :help oil-columns to see which columns are sortable
					{ 'type', 'asc' },
					{ 'name', 'asc' },
				},
			},
			-- Configuration for the floating window in oil.open_float
			float = {
				-- Padding around the floating window
				padding = 2,
				max_width = 0,
				max_height = 0,
				border = 'rounded',
				win_options = {
					winblend = 0,
				},
				-- This is the config that will be passed to nvim_open_win.
				-- Change values here to customize the layout
				override = function(conf)
					return conf
				end,
			},
			-- Configuration for the actions floating preview window
			preview = {
				-- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
				-- min_width and max_width can be a single value or a list of mixed integer/float types.
				-- max_width = {100, 0.8} means "the lesser of 100 columns or 80% of total"
				max_width = 0.9,
				-- min_width = {40, 0.4} means "the greater of 40 columns or 40% of total"
				min_width = { 40, 0.4 },
				-- optionally define an integer/float for the exact width of the preview window
				width = nil,
				-- Height dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
				-- min_height and max_height can be a single value or a list of mixed integer/float types.
				-- max_height = {80, 0.9} means "the lesser of 80 columns or 90% of total"
				max_height = 0.9,
				-- min_height = {5, 0.1} means "the greater of 5 columns or 10% of total"
				min_height = { 5, 0.1 },
				-- optionally define an integer/float for the exact height of the preview window
				height = nil,
				border = 'rounded',
				win_options = { winblend = 0 },
				-- Whether the preview window is automatically updated when the cursor is moved
				update_on_cursor_moved = true,
			},
			-- Configuration for the floating progress window
			progress = {
				max_width = 0.9,
				min_width = { 40, 0.4 },
				width = nil,
				max_height = { 10, 0.9 },
				min_height = { 5, 0.1 },
				height = nil,
				border = 'rounded',
				minimized_border = 'none',
				win_options = { winblend = 0 },
			},
			-- Configuration for the floating SSH window
			ssh = { border = 'rounded' },
		},
		config = function(_, opts)
			local oil = require 'oil'
			oil.setup(opts)

			vim.keymap.set('n', '<leader>of', oil.toggle_float, { desc = 'Toggle Oil in floating window', silent = true })
		end,
	},

	-- Nvim tree
	{
		'nvim-tree/nvim-tree.lua',
		dependencies = {
			'nvim-tree/nvim-web-devicons',
			'antosha417/nvim-lsp-file-operations',
			'echasnovski/mini.base16',
		},
		keys = {
			{
				'<leader>n',
				function()
					require('nvim-tree.api').tree.toggle()
				end,
			},
		},
		-- cmd = {
		--   'NvimTreeOpen',
		--   'NvimTreeClose',
		--   'NvimTreeToggle',
		--   'NvimTreeFocus',
		--   'NvimTreeRefresh',
		--   'NvimTreeFindFile',
		--   'NvimTreeFindFileToggle',
		--   'NvimTreeClipboard',
		--   'NvimTreeResize',
		--   'NvimTreeCollapse',
		--   'NvimTreeCollapseKeepBuffers',
		-- },

		opts = {
			-- Changes how files within the same directory are sorted.
			-- Can be one of `name`, `case_sensitive`, `modification_time`, `extension` or a
			-- function.
			sort_by = 'extension',
			-- Keeps the cursor on the first letter of the filename when moving in the tree.
			hijack_cursor = true,
			-- Changes the tree root directory on `DirChanged` and refreshes the tree.
			sync_root_with_cwd = true,
			-- Will change cwd of nvim-tree to that of new buffer's when opening nvim-tree.
			respect_buf_cwd = true,
			-- Hijacks new directory buffers when they are opened (`:e dir`).
			hijack_directories = { enable = true },
			-- Update the focused file on `BufEnter`, un-collapses the folders recursively
			-- until it finds the file.
			update_focused_file = {
				enable = true,
				-- Update the root directory of the tree if the file is not under current root directory.
				-- It prefers vim's cwd and `root_dirs`. Otherwise it falls back to the folder containing the file.
				-- Only relevant when `update_focused_file.enable` is `true`
				update_root = true,
			},
			-- Use `vim.ui.select` style prompts. Necessary when using a UI prompt decorator
			-- such as dressing.nvim or telescope-ui-select.nvim
			select_prompts = true,
			-- Hide dotfiles by default.
			filters = {
				dotfiles = true,
			},
			-- Window / buffer setup.
			view = {
				-- Resize the window on each draw based on the longest line.
				adaptive_size = true,
				-- Configuration options for floating windows
				float = { enable = true },
			},
			-- UI rendering setup
			renderer = {
				-- Appends a trailing slash to folder names.
				add_trailing = true,
				-- Compact folders that only contain a single folder into one node in the file tree.
				group_empty = false,
				-- Highlight icons and/or names for opened files.
				-- highlight_opened_files = 'all',

				-- Configuration options for tree indent markers.
				indent_markers = { enable = true },
			},
			-- Configuration for tab behaviour.
			tab = {
				-- Configuration for syncing nvim-tree across tabs.
				sync = {
					-- Opens the tree automatically when switching tabpage or opening a new
					-- tabpage if the tree was previously open.
					open = true,
					-- Closes the tree across all tabpages when the tree is closed.
					close = true,
				},
			},
			on_attach = function(bufnr)
				local api = require 'nvim-tree.api'

				local function opts(desc)
					return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end

				local tree_bindings = {
					{ { '<C-]>', 'L' }, api.tree.change_root_to_node,       'CD' },
					{ '<C-e>',          api.node.open.replace_tree_buffer,  'Open: In Place' },
					{ '<C-k>',          api.node.show_info_popup,           'Info' },
					{ '<C-r>',          api.fs.rename_sub,                  'Rename: Omit Filename' },
					{ '<C-t>',          api.node.open.tab,                  'Open: New Tab' },
					{ '<C-v>',          api.node.open.vertical,             'Open: Vertical Split' },
					{ '<C-x>',          api.node.open.horizontal,           'Open: Horizontal Split' },
					{ { '<BS>', 'h' },  api.node.navigate.parent_close,     'Close Directory' },
					{ { '<CR>', 'l' },  api.node.open.edit,                 'Open' },
					{ '<Tab>',          api.node.open.preview,              'Open Preview' },
					{ '>',              api.node.navigate.sibling.next,     'Next Sibling' },
					{ '<',              api.node.navigate.sibling.prev,     'Previous Sibling' },
					{ '.',              api.node.run.cmd,                   'Run Command' },
					{ '-',              api.tree.change_root_to_parent,     'Up' },
					{ 'a',              api.fs.create,                      'Create' },
					{ 'bmv',            api.marks.bulk.move,                'Move Bookmarked' },
					{ 'B',              api.tree.toggle_no_buffer_filter,   'Toggle No Buffer' },
					{ 'c',              api.fs.copy.node,                   'Copy' },
					{ 'C',              api.tree.toggle_git_clean_filter,   'Toggle Git Clean' },
					{ '[c',             api.node.navigate.git.prev,         'Prev Git' },
					{ ']c',             api.node.navigate.git.next,         'Next Git' },
					{ 'd',              api.fs.remove,                      'Delete' },
					{ 'D',              api.fs.trash,                       'Trash' },
					{ 'E',              api.tree.expand_all,                'Expand All' },
					{ 'e',              api.fs.rename_basename,             'Rename: Basename' },
					{ ']e',             api.node.navigate.diagnostics.next, 'Next Diagnostic' },
					{ '[e',             api.node.navigate.diagnostics.prev, 'Prev Diagnostic' },
					{ 'F',              api.live_filter.clear,              'Clean Filter' },
					{ 'f',              api.live_filter.start,              'Filter' },
					{ 'g?',             api.tree.toggle_help,               'Help' },
					{ 'gy',             api.fs.copy.absolute_path,          'Copy Absolute Path' },
					{ 'H',              api.tree.toggle_hidden_filter,      'Toggle Dotfiles' },
					{ 'I',              api.tree.toggle_gitignore_filter,   'Toggle Git Ignore' },
					{ 'J',              api.node.navigate.sibling.last,     'Last Sibling' },
					{ 'K',              api.node.navigate.sibling.first,    'First Sibling' },
					{ 'm',              api.marks.toggle,                   'Toggle Bookmark' },
					{ 'o',              api.node.open.edit,                 'Open' },
					{ 'O',              api.node.open.no_window_picker,     'Open: No Window Picker' },
					{ 'p',              api.fs.paste,                       'Paste' },
					{ 'P',              api.node.navigate.parent,           'Parent Directory' },
					{ 'q',              api.tree.close,                     'Close' },
					{ 'r',              api.fs.rename,                      'Rename' },
					{ 'R',              api.tree.reload,                    'Refresh' },
					{ 's',              api.node.run.system,                'Run System' },
					{ 'S',              api.tree.search_node,               'Search' },
					{ 'U',              api.tree.toggle_custom_filter,      'Toggle Hidden' },
					{ 'W',              api.tree.collapse_all,              'Collapse' },
					{ 'x',              api.fs.cut,                         'Cut' },
					{ 'y',              api.fs.copy.filename,               'Copy Name' },
					{ 'Y',              api.fs.copy.relative_path,          'Copy Relative Path' },
					{ '<2-LeftMouse>',  api.node.open.edit,                 'Open' },
					{ '<2-RightMouse>', api.tree.change_root_to_node,       'CD' },
				}

				for _, rule in ipairs(tree_bindings) do
					local keys = vim.tbl_deep_extend('force', {}, type(rule[1]) == 'string' and { rule[1] } or rule[1]) or {}
					local fn = rule[2]
					local desc = rule[3]

					for _, key in ipairs(keys) do
						vim.keymap.set(rule.mode or 'n', key, fn,
							{ desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true })
					end
				end

				-- Default mappings. Feel free to modify or remove as you wish.
				--
				-- BEGIN_DEFAULT_ON_ATTACH
				-- vim.keymap.set('n', '<C-]>', api.tree.change_root_to_node, opts 'CD')
				-- vim.keymap.set('n', '<C-e>', api.node.open.replace_tree_buffer, opts 'Open: In Place')
				-- vim.keymap.set('n', '<C-k>', api.node.show_info_popup, opts 'Info')
				-- vim.keymap.set('n', '<C-r>', api.fs.rename_sub, opts 'Rename: Omit Filename')
				-- vim.keymap.set('n', '<C-t>', api.node.open.tab, opts 'Open: New Tab')
				-- vim.keymap.set('n', '<C-v>', api.node.open.vertical, opts 'Open: Vertical Split')
				-- vim.keymap.set('n', '<C-x>', api.node.open.horizontal, opts 'Open: Horizontal Split')
				-- vim.keymap.set('n', '<BS>', api.node.navigate.parent_close, opts 'Close Directory')
				-- vim.keymap.set('n', '<CR>', api.node.open.edit, opts 'Open')
				-- vim.keymap.set('n', '<Tab>', api.node.open.preview, opts 'Open Preview')
				-- vim.keymap.set('n', '>', api.node.navigate.sibling.next, opts 'Next Sibling')
				-- vim.keymap.set('n', '<', api.node.navigate.sibling.prev, opts 'Previous Sibling')
				-- vim.keymap.set('n', '.', api.node.run.cmd, opts 'Run Command')
				-- vim.keymap.set('n', '-', api.tree.change_root_to_parent, opts 'Up')
				-- vim.keymap.set('n', 'a', api.fs.create, opts 'Create')
				-- vim.keymap.set('n', 'bmv', api.marks.bulk.move, opts 'Move Bookmarked')
				-- vim.keymap.set('n', 'B', api.tree.toggle_no_buffer_filter, opts 'Toggle No Buffer')
				-- vim.keymap.set('n', 'c', api.fs.copy.node, opts 'Copy')
				-- vim.keymap.set('n', 'C', api.tree.toggle_git_clean_filter, opts 'Toggle Git Clean')
				-- vim.keymap.set('n', '[c', api.node.navigate.git.prev, opts 'Prev Git')
				-- vim.keymap.set('n', ']c', api.node.navigate.git.next, opts 'Next Git')
				-- vim.keymap.set('n', 'd', api.fs.remove, opts 'Delete')
				-- vim.keymap.set('n', 'D', api.fs.trash, opts 'Trash')
				-- vim.keymap.set('n', 'E', api.tree.expand_all, opts 'Expand All')
				-- vim.keymap.set('n', 'e', api.fs.rename_basename, opts 'Rename: Basename')
				-- vim.keymap.set('n', ']e', api.node.navigate.diagnostics.next, opts 'Next Diagnostic')
				-- vim.keymap.set('n', '[e', api.node.navigate.diagnostics.prev, opts 'Prev Diagnostic')
				-- vim.keymap.set('n', 'F', api.live_filter.clear, opts 'Clean Filter')
				-- vim.keymap.set('n', 'f', api.live_filter.start, opts 'Filter')
				-- vim.keymap.set('n', 'g?', api.tree.toggle_help, opts 'Help')
				-- vim.keymap.set('n', 'gy', api.fs.copy.absolute_path, opts 'Copy Absolute Path')
				-- vim.keymap.set('n', 'H', api.tree.toggle_hidden_filter, opts 'Toggle Dotfiles')
				-- vim.keymap.set('n', 'I', api.tree.toggle_gitignore_filter, opts 'Toggle Git Ignore')
				-- vim.keymap.set('n', 'J', api.node.navigate.sibling.last, opts 'Last Sibling')
				-- vim.keymap.set('n', 'K', api.node.navigate.sibling.first, opts 'First Sibling')
				-- vim.keymap.set('n', 'm', api.marks.toggle, opts 'Toggle Bookmark')
				-- vim.keymap.set('n', 'o', api.node.open.edit, opts 'Open')
				-- vim.keymap.set('n', 'O', api.node.open.no_window_picker, opts 'Open: No Window Picker')
				-- vim.keymap.set('n', 'p', api.fs.paste, opts 'Paste')
				-- vim.keymap.set('n', 'P', api.node.navigate.parent, opts 'Parent Directory')
				-- vim.keymap.set('n', 'q', api.tree.close, opts 'Close')
				-- vim.keymap.set('n', 'r', api.fs.rename, opts 'Rename')
				-- vim.keymap.set('n', 'R', api.tree.reload, opts 'Refresh')
				-- vim.keymap.set('n', 's', api.node.run.system, opts 'Run System')
				-- vim.keymap.set('n', 'S', api.tree.search_node, opts 'Search')
				-- vim.keymap.set('n', 'U', api.tree.toggle_custom_filter, opts 'Toggle Hidden')
				-- vim.keymap.set('n', 'W', api.tree.collapse_all, opts 'Collapse')
				-- vim.keymap.set('n', 'x', api.fs.cut, opts 'Cut')
				-- vim.keymap.set('n', 'y', api.fs.copy.filename, opts 'Copy Name')
				-- vim.keymap.set('n', 'Y', api.fs.copy.relative_path, opts 'Copy Relative Path')
				-- vim.keymap.set('n', '<2-LeftMouse>', api.node.open.edit, opts 'Open')
				-- vim.keymap.set('n', '<2-RightMouse>', api.tree.change_root_to_node, opts 'CD')
				-- -- END_DEFAULT_ON_ATTACH

				-- -- Mappings migrated from view.mappings.list
				-- --
				-- -- You will need to insert "your code goes here" for any mappings with a custom action_cb
				-- vim.keymap.set('n', 'l', api.node.open.edit, opts 'Open')
				-- vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts 'Close Directory')
				-- vim.keymap.set('n', 'L', api.tree.change_root_to_node, opts 'CD')
			end,
		},
	},

	-- Adds task management
	{
		'stevearc/overseer.nvim',
		keys = {
			{ '<leader>ot', lazy_load { 'overseer', 'toggle', { enter = false } } },
		},
		opts = {
			-- Default task strategy
			strategy = 'terminal',
			-- Template modules to load
			templates = { 'builtin' },
			-- When true, tries to detect a green color from your colorscheme to use for success highlight
			auto_detect_success_color = true,
			-- Patch nvim-dap to support preLaunchTask and postDebugTask
			dap = true,
			-- Configure the task list
			task_list = {
				-- Default detail level for tasks. Can be 1-3.
				default_detail = 1,
				-- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
				-- min_width and max_width can be a single value or a list of mixed integer/float types.
				-- max_width = {100, 0.2} means "the lesser of 100 columns or 20% of total"
				max_width = { 100, 0.2 },
				-- min_width = {40, 0.1} means "the greater of 40 columns or 10% of total"
				min_width = { 40, 0.1 },
				-- optionally define an integer/float for the exact width of the task list
				width = nil,
				max_height = { 20, 0.1 },
				min_height = 8,
				height = nil,
				-- String that separates tasks
				separator = '────────────────────────────────────────',
				-- Default direction. Can be "left", "right", or "bottom"
				direction = 'bottom',
				-- Set keymap to false to remove default behavior
				-- You can add custom keymaps here as well (anything vim.keymap.set accepts)
				bindings = {
					['?'] = 'ShowHelp',
					['<CR>'] = 'RunAction',
					['<C-e>'] = 'Edit',
					['o'] = 'Open',
					['<C-v>'] = 'OpenVsplit',
					['<C-s>'] = 'OpenSplit',
					['<C-f>'] = 'OpenFloat',
					['<C-q>'] = 'OpenQuickFix',
					['p'] = 'TogglePreview',
					['+'] = 'IncreaseDetail',
					['-'] = 'DecreaseDetail',
					['L'] = 'IncreaseAllDetail',
					['H'] = 'DecreaseAllDetail',
					['['] = 'DecreaseWidth',
					[']'] = 'IncreaseWidth',
					['{'] = 'PrevTask',
					['}'] = 'NextTask',
				},
			},
			-- See :help overseer-actions
			actions = {},
			-- Configure the floating window used for task templates that require input
			-- and the floating window used for editing tasks
			form = {
				border = 'rounded',
				zindex = 40,
				-- Dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
				-- min_X and max_X can be a single value or a list of mixed integer/float types.
				min_width = 80,
				max_width = 0.9,
				width = nil,
				min_height = 10,
				max_height = 0.9,
				height = nil,
				-- Set any window options here (e.g. winhighlight)
				win_opts = {
					winblend = 0,
				},
			},
			task_launcher = {
				-- Set keymap to false to remove default behavior
				-- You can add custom keymaps here as well (anything vim.keymap.set accepts)
				bindings = {
					i = {
						['<C-s>'] = 'Submit',
						['<C-c>'] = 'Cancel',
					},
					n = {
						['<CR>'] = 'Submit',
						['<C-s>'] = 'Submit',
						['q'] = 'Cancel',
						['?'] = 'ShowHelp',
					},
				},
			},
			task_editor = {
				-- Set keymap to false to remove default behavior
				-- You can add custom keymaps here as well (anything vim.keymap.set accepts)
				bindings = {
					i = {
						['<CR>'] = 'NextOrSubmit',
						['<C-s>'] = 'Submit',
						['<Tab>'] = 'Next',
						['<S-Tab>'] = 'Prev',
						['<C-c>'] = 'Cancel',
					},
					n = {
						['<CR>'] = 'NextOrSubmit',
						['<C-s>'] = 'Submit',
						['<Tab>'] = 'Next',
						['<S-Tab>'] = 'Prev',
						['q'] = 'Cancel',
						['?'] = 'ShowHelp',
					},
				},
			},
			-- Configure the floating window used for confirmation prompts
			confirm = {
				border = 'rounded',
				zindex = 40,
				-- Dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
				-- min_X and max_X can be a single value or a list of mixed integer/float types.
				min_width = 20,
				max_width = 0.5,
				width = nil,
				min_height = 6,
				max_height = 0.9,
				height = nil,
				-- Set any window options here (e.g. winhighlight)
				win_opts = {
					winblend = 0,
				},
			},
			-- Configuration for task floating windows
			task_win = {
				-- How much space to leave around the floating window
				padding = 2,
				border = 'rounded',
				-- Set any window options here (e.g. winhighlight)
				win_opts = {
					winblend = 0,
				},
			},
			-- Aliases for bundles of components. Redefine the builtins, or create your own.
			component_aliases = {
				-- Most tasks are initialized with the default components
				default = {
					{ 'display_duration', detail_level = 2 },
					'on_output_summarize',
					'on_exit_set_status',
					'on_complete_notify',
					'on_complete_dispose',
				},
				-- Tasks from tasks.json use these components
				default_vscode = {
					'default',
					'on_result_diagnostics',
					'on_result_diagnostics_quickfix',
				},
			},
			bundles = {
				-- When saving a bundle with OverseerSaveBundle or save_task_bundle(), filter the tasks with
				-- these options (passed to list_tasks())
				save_task_opts = { bundleable = true },
			},
			-- A list of components to preload on setup.
			-- Only matters if you want them to show up in the task editor.
			preload_components = {},
			-- Controls when the parameter prompt is shown when running a template
			--   always    Show when template has any params
			--   missing   Show when template has any params not explicitly passed in
			--   allow     Only show when a required param is missing
			--   avoid     Only show when a required param with no default value is missing
			--   never     Never show prompt (error if required param missing)
			default_template_prompt = 'allow',
			-- For template providers, how long to wait (in ms) before timing out.
			-- Set to 0 to disable timeouts.
			template_timeout = 3000,
			-- Cache template provider results if the provider takes longer than this to run.
			-- Time is in ms. Set to 0 to disable caching.
			template_cache_threshold = 100,
			-- Configure where the logs go and what level to use
			-- Types are "echo", "notify", and "file"
			log = {
				{ type = 'echo', level = vim.log.levels.WARN },
				{ type = 'file', filename = 'overseer.log',  level = vim.log.levels.WARN },
			},
		},
	},

	-- This plugin
	{
		'Zeioth/compiler.nvim',
		cmd = { 'CompilerOpen', 'CompilerToggleResults', 'CompilerRedo' },
		dependencies = { 'stevearc/overseer.nvim' },
		opts = {},
	},

	-- Tmux pane navigation assistant
	-- {
	--   'connordeckers/tmux-navigator.nvim',
	--
	--   keys = {
	--     { '<C-h>', navigate 'left', desc = 'Move to the panel on the left' }, -- Move left
	--     { '<C-j>', navigate 'down', desc = 'Move to the panel below' }, -- Move down
	--     { '<C-k>', navigate 'up', desc = 'Move to the panel above' }, -- Move up
	--     { '<C-l>', navigate 'right', desc = 'Move to the panel on the right' }, -- Move right
	--   },
	--
	--   opts = {
	--     enabled = true,
	--     DisableMapping = true,
	--     DisableWhenZoomed = true,
	--   },
	-- },
	{
		'mrjones2014/smart-splits.nvim',
		lazy = false,
		keys = {
			-- recommended mappings
			-- resizing splits
			-- these keymaps will also accept a range,
			-- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
			{ '<A-h>', lazy_load { 'smart-splits', 'resize_left', 3 } },
			{ '<A-j>', lazy_load { 'smart-splits', 'resize_down', 3 } },
			{ '<A-k>', lazy_load { 'smart-splits', 'resize_up', 3 } },
			{ '<A-l>', lazy_load { 'smart-splits', 'resize_right', 3 } },

			-- moving between splits
			{ '<C-h>', lazy_load { 'smart-splits', 'move_cursor_left' } },
			{ '<C-j>', lazy_load { 'smart-splits', 'move_cursor_down' } },
			{ '<C-k>', lazy_load { 'smart-splits', 'move_cursor_up' } },
			{ '<C-l>', lazy_load { 'smart-splits', 'move_cursor_right' } },

			-- swapping buffers between windows
			-- {
			--   '<leader><leader>h',
			--   lazy_load { 'smart-splits', 'swap_buf_left' },
			-- },
			-- {
			--   '<leader><leader>j',
			--   lazy_load { 'smart-splits', 'swap_buf_down' },
			-- },
			-- {
			--   '<leader><leader>k',
			--   lazy_load { 'smart-splits', 'swap_buf_up' },
			-- },
			-- {
			--   '<leader><leader>l',
			--   lazy_load { 'smart-splits', 'swap_buf_right' },
			-- },
		},
		opts = {
			-- Ignored buffer types (only while resizing)
			-- ignored_buftypes = { 'nofile', 'quickfix', 'prompt' },

			-- Ignored filetypes (only while resizing)
			-- ignored_filetypes = { 'NvimTree' },

			-- the default number of lines/columns to resize by at a time
			-- default_amount = 3,

			-- Desired behavior when your cursor is at an edge and you
			-- are moving towards that same edge:
			-- 'wrap' => Wrap to opposite side
			-- 'split' => Create a new split in the desired direction
			-- 'stop' => Do nothing
			-- function => You handle the behavior yourself
			-- NOTE: If using a function, the function will be called with
			-- a context object with the following fields:
			-- {
			--    mux = {
			--      type:'tmux'|'wezterm'|'kitty'
			--      current_pane_id():number,
			--      is_in_session(): boolean
			--      current_pane_is_zoomed():boolean,
			--      -- following methods return a boolean to indicate success or failure
			--      current_pane_at_edge(direction:'left'|'right'|'up'|'down'):boolean
			--      next_pane(direction:'left'|'right'|'up'|'down'):boolean
			--      resize_pane(direction:'left'|'right'|'up'|'down'):boolean
			--      split_pane(direction:'left'|'right'|'up'|'down',size:number|nil):boolean
			--    },
			--    direction = 'left'|'right'|'up'|'down',
			--    split(), -- utility function to split current Neovim pane in the current direction
			--    wrap(), -- utility function to wrap to opposite Neovim pane
			-- }
			-- NOTE: `at_edge = 'wrap'` is not supported on Kitty terminal
			-- multiplexer, as there is no way to determine layout via the CLI
			-- at_edge = 'wrap',
			-- when moving cursor between splits left or right,
			-- place the cursor on the same row of the *screen*
			-- regardless of line numbers. False by default.
			-- Can be overridden via function parameter, see Usage.
			-- move_cursor_same_row = false,
			-- whether the cursor should follow the buffer when swapping
			-- buffers by default; it can also be controlled by passing
			-- `{ move_cursor = true }` or `{ move_cursor = false }`
			-- when calling the Lua function.
			-- cursor_follows_swapped_bufs = false,
			-- resize mode options
			resize_mode = {
				-- key to exit persistent resize mode
				quit_key = '<ESC>',
				-- keys to use for moving in resize mode
				-- in order of left, down, up' right
				resize_keys = { 'h', 'j', 'k', 'l' },
				-- set to true to silence the notifications
				-- when entering/exiting persistent resize mode
				silent = false,
			},
			-- ignore these autocmd events (via :h eventignore) while processing
			-- smart-splits.nvim computations, which involve visiting different
			-- buffers and windows. These events will be ignored during processing,
			-- and un-ignored on completed. This only applies to resize events,
			-- not cursor movement events.
			-- ignored_events = { 'BufEnter', 'WinEnter' },

			-- enable or disable a multiplexer integration;
			-- automatically determined, unless explicitly disabled or set,
			-- by checking the $TERM_PROGRAM environment variable,
			-- and the $KITTY_LISTEN_ON environment variable for Kitty
			-- multiplexer_integration = 'tmux',
			-- multiplexer_integration = 'wezterm',

			-- disable multiplexer navigation if current multiplexer pane is zoomed
			-- this functionality is only supported on tmux and Wezterm due to kitty
			-- not having a way to check if a pane is zoomed
			disable_multiplexer_nav_when_zoomed = true,
			-- Supply a Kitty remote control password if needed,
			-- or you can also set vim.g.smart_splits_kitty_password
			-- see https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.remote_control_password
			-- kitty_password = nil,

			-- default logging level, one of: 'trace'|'debug'|'info'|'warn'|'error'|'fatal'
			log_level = 'info',
		},
	},

	-- Rooter changes the working directory to the project root when you open a file or directory.
	-- 'airblade/vim-rooter',
	-- {
	--   'ahmedkhalf/project.nvim',
	--   main = 'project_nvim',
	--   event = 'VeryLazy',
	--   opts = {
	--     -- Manual mode doesn't automatically change your root directory, so you have
	--     -- the option to manually do so using `:ProjectRoot` command.
	--     manual_mode = false,
	--     -- Methods of detecting the root directory. **"lsp"** uses the native neovim
	--     -- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
	--     -- order matters: if one is not detected, the other is used as fallback. You
	--     -- can also delete or rearangne the detection methods.
	--     detection_methods = { 'lsp', 'pattern' },
	--     -- All the patterns used to detect root dir, when **"pattern"** is in
	--     -- detection_methods
	--     patterns = { '.projectroot', '.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', 'package.json' },
	--     -- Table of lsp clients to ignore by name
	--     -- eg: { "efm", ... }
	--     ignore_lsp = {},
	--     -- Don't calculate root dir on specific directories
	--     -- Ex: { "~/.cargo/*", ... }
	--     exclude_dirs = {},
	--     -- Show hidden files in telescope
	--     show_hidden = false,
	--     -- When set to false, you will get a message when project.nvim changes your
	--     -- directory.
	--     silent_chdir = true,
	--     -- What scope to change the directory, valid options are
	--     -- * global (default)
	--     -- * tab
	--     -- * win
	--     scope_chdir = 'global',
	--     -- Path where project.nvim will store the project history for use in
	--     -- telescope
	--     datapath = vim.fn.stdpath 'data',
	--   },
	-- },
	-- Some nice git features
	{
		'lewis6991/gitsigns.nvim',
		event = 'VeryLazy',
		opts = {
			signcolumn = false,
			numhl = true,
			linehl = false,
			word_diff = false,
			watch_gitdir = { interval = 1000, follow_files = true },
			attach_to_untracked = true,
			current_line_blame = true,
			current_line_blame_opts = { virt_text = true, virt_text_pos = 'eol', delay = 500 },
			-- current_line_blame_formatter_opts = { relative_time = false },
			current_line_blame_formatter = '<summary> (<author> | <author_time:%Y-%m-%d>)',
			sign_priority = 6,
			update_debounce = 150,
			status_formatter = nil,
			max_file_length = 40000,
			preview_config = {
				border = 'single',
				style = 'minimal',
				relative = 'cursor',
				row = 0,
				col = 1,
			},
		},
	},

	{
		'sindrets/diffview.nvim',
		cmd = {
			'DiffviewOpen',
			'DiffviewFileHistory',
			'DiffviewClose',
			'DiffviewFocusFiles',
			'DiffviewToggleFiles',
			'DiffviewRefresh',
			'DiffviewLog',
		},
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		keys = {
			{
				'<leader>gd',
				'<cmd>DiffviewOpen<cr>',
				desc = 'Open a diff view for the current buffer',
			},
		},
	},

	-- Surround text with other text. Neat!
	{
		'kylechui/nvim-surround',
		event = 'VeryLazy',
		dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
		opts = {},
	},

	-- {
	--   'roobert/surround-ui.nvim',
	--   event = 'VeryLazy',
	--   dependencies = { 'nvim-surround', 'which-key.nvim' },
	--   opts = { root_key = 'S' },
	-- },

	-- Lightspeed navigation, but better!
	{
		'ggandor/leap.nvim',
		event = 'BufRead',
		dependencies = {
			'tpope/vim-repeat',
			{ 'ggandor/flit.nvim', config = true },
			{
				{
					'ggandor/leap-spooky.nvim',
					opts = {
						affixes = {
							-- These will generate mappings for all native text objects, like:
							-- (ir|ar|iR|aR|im|am|iM|aM){obj}.
							-- Special line objects will also be added, by repeating the affixes.
							-- E.g. `yrr<leap>` and `ymm<leap>` will yank a line in the current
							-- window.
							-- r - cursor doesn't move to the targeted position
							-- m - cursor moves to the targeted position
							-- You can also use 'rest' & 'move' as mnemonics.
							remote = { window = 'r', cross_window = 'R' },
							magnetic = { window = 'm', cross_window = 'M' },
						},
						-- If this option is set to true, the yanked text will automatically be pasted
						-- at the cursor position if the unnamed register is in use.
						paste_on_remote_yank = false,
					},
				},
			},
		},
		config = function()
			require('leap').add_default_mappings()
		end,
	},

	-- Better, easier, structural renaming.
	{
		'cshuaimin/ssr.nvim',
		keys = {
			{
				'<leader>sr',
				mode = { 'n', 'x' },
				function()
					require('ssr').open()
				end,
			},
		},
		opts = {
			min_width = 50,
			min_height = 5,
			keymaps = {
				close = 'q',
				next_match = 'n',
				prev_match = 'N',
				replace_all = '<leader><cr>',
			},
		},
	},

	-- Commenting tool
	{
		'numtostr/comment.nvim',
		dependencies = { 'nvim-ts-context-commentstring' },
		keys = {
			-- Toggle current line (linewise) using C-i
			{
				'<leader>ci',
				function()
					require('Comment.api').toggle.linewise.current()
				end,
			},
			{
				'<leader>ci',
				function()
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<ESC>', true, false, true), 'nx', false)
					require('Comment.api').toggle.linewise(vim.fn.visualmode())
				end,
				mode = 'x',
			},

			-- Toggle current line (blockwise) using C-b
			{
				'<leader>cb',
				function()
					require('Comment.api').toggle.blockwise.current()
				end,
			},

			{
				'<leader>cb',
				function()
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<ESC>', true, false, true), 'nx', false)
					require('Comment.api').toggle.blockwise(vim.fn.visualmode())
				end,
				mode = 'x',
			},

			-- Toggle lines (linewise) with dot-repeat support
			-- Example: <leader>gc3j will comment 4 lines
			{
				'<leader>gc',
				function()
					require('Comment.api').call('toggle.linewise', 'g@')
				end,
				expr = true,
			},

			-- Toggle lines (blockwise) with dot-repeat support
			-- Example: <leader>gb3j will comment 4 lines
			{
				'<leader>gb',
				function()
					require('Comment.api').call('toggle.blockwise', 'g@')
				end,
				expr = true,
			},
		},
		opts = {
			---Add a space b/w comment and the line
			---@type boolean|fun():boolean
			padding = true,
			---Whether the cursor should stay at its position
			---NOTE: This only affects NORMAL mode mappings and doesn't work with dot-repeat
			---@type boolean
			sticky = true,
			---Lines to be ignored while comment/uncomment.
			---Could be a regex string or a function that returns a regex string.
			---Example: Use '^$' to ignore empty lines
			---@type string|fun():string
			-- ignore = nil,
			ignore = '^$',
			---Create basic (operator-pending) and extended mappings for NORMAL + VISUAL mode
			---NOTE: If `mappings = false` then the plugin won't create any mappings
			---@type boolean|table
			mappings = {
				basic = false,
				extra = false,
			},
			---Pre-hook, called before commenting the line
			---@type fun(ctx:CommentCtx):any|nil
			pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
			---Post-hook, called after commenting is done
			---@type fun(ctx: CommentCtx)
			-- post_hook = nil,
		},
	},

	-- Continuously updated session files
	{ 'tpope/vim-obsession',   cmd = 'Obsess' },

	-- {
	--   'mbbill/undotree',
	--   cmd = { 'UndotreeToggle' },
	--   keys = { { '<leader>u', '<cmd>UndotreeToggle<cr>' } },
	-- },

	{
		'akinsho/toggleterm.nvim',
		keys = { { '<leader>tt' } },
		opts = {
			open_mapping = [[<leader>tt]],
			hide_numbers = true,      -- hide the number column in toggleterm buffers
			start_in_insert = true,
			insert_mappings = false,  -- whether or not the open mapping applies in insert mode
			terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
			persist_size = true,
			persist_mode = true,      -- if set to true (default) the previous terminal mode will be remembered
			direction = 'float',
			close_on_exit = true,     -- close the terminal window when the process exits
			-- Change the default shell. Can be a string or a function returning a string
			shell = vim.o.shell,
			auto_scroll = true, -- automatically scroll to the bottom on terminal output
			-- This field is only relevant if direction is set to 'float'
			float_opts = {
				-- The border key is *almost* the same as 'nvim_open_win'
				-- see :h nvim_open_win for details on borders however
				-- the 'curved' border is a custom border type
				-- not natively supported but implemented in this plugin.
				border = 'single',
				-- like `size`, width and height can be a number or function which is passed the current terminal
				winblend = 0,
			},
		},
	},

	-- {
	-- 	'nvim-neorg/neorg',
	-- 	dependencies = {
	-- 		{ 'vhyrro/luarocks.nvim', priority = 1000, config = true },
	-- 	},
	-- 	lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
	-- 	version = '*', -- Pin Neorg to the latest stable release
	-- 	config = true,
	-- },

	{
		'gbprod/yanky.nvim',
		dependencies = { 'telescope.nvim' },
		keys = {
			{ 'p',     '<Plug>(YankyPutAfter)',            mode = { 'n', 'x' } },
			{ 'P',     '<Plug>(YankyPutBefore)',           mode = { 'n', 'x' } },
			{ 'gp',    '<Plug>(YankyGPutAfter)',           mode = { 'n', 'x' } },
			{ 'gP',    '<Plug>(YankyGPutBefore)',          mode = { 'n', 'x' } },
			{ '<c-p>', '<Plug>(YankyPreviousEntry)',       mode = 'n' },
			{ '<c-n>', '<Plug>(YankyNextEntry)',           mode = 'n' },
			{ '"',     telescope_extension 'yank_history', mode = 'n' },
		},
		config = function()
			require('yanky').setup {
				system_clipboard = { sync_with_ring = true },
				highlight = { on_put = true, on_yank = true, timer = 300 },
				preserve_cursor_position = { enabled = true },
				textobj = { enabled = true },
			}

			require('telescope').load_extension 'yank_history'
		end,
	},
}
