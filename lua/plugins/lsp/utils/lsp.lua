local lsp = {}

--- @param key string
--- @param prop string | function | KeybindTable | KeybindTable[]
--- @param buffer? number
function lsp.mapkey(key, prop, buffer)
	local function is_array(tbl)
		return type(tbl) == 'table' and (#tbl > 0 or next(tbl) == nil)
	end

	local default_opts = { noremap = true, silent = true, buffer = buffer }

	--- @type { mode: string[], action: function | string, options: KeybindOptions }[]
	local normalised_mappings = {}

	if type(prop) == 'string' or type(prop) == 'function' then
		table.insert(normalised_mappings, { mode = { 'n' }, action = prop, options = default_opts })
	end

	if type(prop) == 'table' then
		if is_array(prop) then
			for _, p in pairs(prop) do
				local mode = is_array(p.mode) and p.mode or { p.mode }
				local options = vim.tbl_deep_extend('force', default_opts, p.options or {})
				table.insert(normalised_mappings, { mode = mode, action = p.action, options = options })
			end
		else
			local mode = is_array(prop.mode) and prop.mode or { prop.mode }
			local options = vim.tbl_deep_extend('force', default_opts, prop.options or {})
			table.insert(normalised_mappings, { mode = mode, action = prop.action, options = options })
		end
	end

	for _, param in pairs(normalised_mappings) do
		for _, mode in pairs(param.mode) do
			vim.keymap.set(mode, key, param.action, param.options)
		end
	end
end

---@param	keymaps table<string, string | function | KeybindTable | KeybindTable[]>
---@param buffer? number
function lsp.mapkeys(keymaps, buffer)
	for key, map in pairs(keymaps) do
		lsp.mapkey(key, map, buffer)
	end
end

return lsp
