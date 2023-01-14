local name = vim.fn.system('git config user.name'):gsub("%s+", "");
local date = os.date('%Y%m%d')

local function GetCommentFormat()
	-- Only calculate commentstring for tsx filetypes
	local utils = require 'ts_context_commentstring.utils'
	local inter = require 'ts_context_commentstring.internal'

	-- Determine whether to use linewise or blockwise commentstring
	local type = '__default'

	-- Determine the location where to calculate commentstring from
	local location = utils.get_cursor_location()

	return inter.calculate_commentstring({ key = type, location = location })
	--end
end

local function Comment(msg)
	return string.format(GetCommentFormat(), msg)
end

print(Comment(string.format('TODO @%s %s - ', name, date)))
