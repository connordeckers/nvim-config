local pickers = require 'telescope.pickers'

local previewer = require 'patch.modules.angular.previewer'
local finder = require 'patch.modules.angular.finder'
local sorter = require 'patch.modules.angular.sorter'

local function show_angular_components(opts)
	opts = opts or {}

	-- Get the project or git root
	local clients = vim.lsp.get_active_clients()
	local gitroot = vim.fn.systemlist("git rev-parse --show-toplevel")[1]

	if clients and clients[1] and clients[1].config.root_dir then
		opts.cwd = clients[1].config.root_dir
	elseif vim.v.shell_error ~= 0 and not gitroot:find("fatal:") then
		opts.cwd = gitroot
	end

	if opts.cwd then
		opts.cwd = vim.fn.expand(opts.cwd)
	end

	pickers.new(opts, {
		prompt_title = "Angular Project",
		finder = finder(opts),
		previewer = previewer(opts),
		sorter = sorter(opts)
	}):find()

end

-- show_angular_components()
-- show_angular_components(theme.get_dropdown({}))

return show_angular_components
