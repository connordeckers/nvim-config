local array = {}

function array.has(tbl, val)
	for _, v in ipairs(tbl) do
		if v == val then return true end
	end
	return false
end

return array
