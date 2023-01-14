local M = {}

M.filter = function(tbl, predicate)
	local out = {}

	for k,v in pairs(tbl) do
		if predicate(v, k, tbl) then table.insert(out, v) end
	end

	return out
end

return M
