local M = {}

---@param hex_str string hexadecimal value of a color
function M.hex_to_rgb(hex_str)
	local hex = '[abcdef0-9][abcdef0-9]'
	local pat = '^#(' .. hex .. ')(' .. hex .. ')(' .. hex .. ')$'
	hex_str = string.lower(hex_str)

	assert(string.find(hex_str, pat) ~= nil, 'hex_to_rgb: invalid hex_str: ' .. tostring(hex_str))

	local red, green, blue = string.match(hex_str, pat)
	return { tonumber(red, 16), tonumber(green, 16), tonumber(blue, 16) }
end

---@param fg string forecrust color
---@param bg string background color
---@param alpha number number between 0 and 1. 0 results in bg, 1 results in fg
function M.blend(fg, bg, alpha)
	local bg_rgb = M.hex_to_rgb(bg)
	local fg_rgb = M.hex_to_rgb(fg)

	local blendChannel = function(i)
		local ret = (alpha * fg_rgb[i] + ((1 - alpha) * bg_rgb[i]))
		return math.floor(math.min(math.max(0, ret), 255) + 0.5)
	end

	return string.format('#%02X%02X%02X', blendChannel(1), blendChannel(2), blendChannel(3))
end

---@param palette CtpColors<string> Catppuccin colour palette
function M.customCatppuccinHighlight(palette)
	local function subtle(color)
		return M.blend(color, palette.base, 0.25)
	end

	return {
		IndentBlanklineChar = { fg = palette.surface0 },
		IndentBlanklineContextChar = { fg = palette.overlay1 },
		IndentBlanklineContextStart = { sp = palette.overlay1, style = { 'underline' } },

		IndentBlanklineIndent6 = { fg = subtle(palette.yellow) },
		IndentBlanklineIndent5 = { fg = subtle(palette.red) },
		IndentBlanklineIndent4 = { fg = subtle(palette.teal) },
		IndentBlanklineIndent3 = { fg = subtle(palette.peach) },
		IndentBlanklineIndent2 = { fg = subtle(palette.blue) },
		IndentBlanklineIndent1 = { fg = subtle(palette.pink) },

		-- IndentBlanklineIndent1 = { bg = blend(palette.mantle, palette.base, 0.5) },
		-- IndentBlanklineIndent2 = { bg = palette.base },
	}
end

return M
