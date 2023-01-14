local renderer = require 'patch.modules.angular.renderer'
local config = require 'patch.modules.angular.config'
local finders = require 'telescope.finders'
local utils = require 'patch.utils'

local function filter_angular_files(entry)
	for ext, _ in pairs(config.item_types) do
		local test = ext:gsub("%*", ".*")
		if entry:match(test) ~= nil then
			return true
		end
	end
	return false
end

local function find_angular_items(opts)
	opts = opts or {}
	opts.filter = opts.filter or filter_angular_files

	local command = "fd --type f --strip-cwd-prefix ."
	local items = vim.fn.systemlist(command)

	local results = utils.filter(items, opts.filter)

	local entry_maker = renderer.make_entry(opts)

	return finders.new_table {
		results = results,
		entry_maker = entry_maker
	}
end

return find_angular_items
