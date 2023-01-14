local devicons = require 'nvim-web-devicons'
local Path = require "plenary.path"
local entry_display = require 'telescope.pickers.entry_display'

local conf = require 'telescope.config'.values
local config = require 'patch.modules.angular.config'

if not devicons.has_loaded() then
	devicons.setup()
end

local exports = {}
local row = {}

local function get_devicon(filename, disable_devicons)
	if disable_devicons or not filename then
		return "", ""
	end

	local icon, icon_highlight = devicons.get_icon(
		filename,
		string.match(filename, "%a+$"),
		{ default = true }
	)

	if conf.color_devicons then
		return icon, icon_highlight
	else
		return icon, "TelescopeResultsFileIcon"
	end
end

function row.display(opts, match)
	return function(entry)
		local display = entry.label

		local displayer = entry_display.create {
			separator = " ",
			items = {
				{ width = 2 },
				{ width = 46 },
				{ width = 25, right_justify = true }
			}
		}

		local itemtype = match.label
		local icon, icon_hl = get_devicon(entry.value, opts.disable_devicons)

		local selector = nil
		if match.selector then
			local matcher = vim.fn.systemlist('grep -Po "' .. match.selector .. ': [\'\\"]\\K[^\'\\"]*" ' .. entry.path)
			if matcher and matcher[1] then
				selector = matcher[1]
			end
		end

		local extra = ""
		if selector then
			extra = selector .. " [" .. itemtype:sub(1, 1) .. "]"
		else
			extra = itemtype
		end

		return displayer {
			{ icon, icon_hl },
			{ display },
			{ extra, "Grey" }
		}
	end
end

function row.ordinal(match, entry)
	return (match.ordinal or "0") .. entry
end

function exports.make_entry(opts)
	opts = opts or {}

	local cwd = vim.fn.expand(opts.cwd or vim.loop.cwd())

	return function(entry)
		local match = nil

		for ext, result in pairs(config.item_types) do
			local test = ext:gsub("%*", ".*")
			if string.match(entry, test) ~= nil then
				match = result
			end
		end


		return {
			cwd = cwd,
			display = row.display(opts, match),
			src = entry,
			path = Path:new({ cwd, entry }):absolute(),
			ordinal = row.ordinal(match, entry),
			name = 'name',
			value = entry,
			label = entry:match(".*src/([^.]*)%..*")
		}
	end
end

return exports
