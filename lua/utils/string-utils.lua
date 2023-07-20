local M = {}

M.trim = function(str)
  return str:gsub('^%s*(.-)%s*$', '%1')
end

M.split = function(search, sep)
  sep = sep == nil and '%s' or sep
  local matches = {}

  for str in string.gmatch(search, '([^' .. sep .. ']+)') do
    table.insert(matches, str)
  end

  return matches
end

return M
