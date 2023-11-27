local TSPrebuild = {}
local has_prebuilt = false

TSPrebuild.on_attach = function(client, bufnr)
  if has_prebuilt then
    return
  end

  local query = require 'vim.treesitter.query'

  local function safe_read(filename, read_quantifier)
    local file, err = io.open(filename, 'r')
    if not file then
      error(err)
    end
    local content = file:read(read_quantifier)
    io.close(file)
    return content
  end

  local function read_query_files(filenames)
    local contents = {}

    for _, filename in ipairs(filenames) do
      table.insert(contents, safe_read(filename, '*a'))
    end

    return table.concat(contents, '')
  end

  local function prebuild_query(lang, query_name)
    local query_files = query.get_files(lang, query_name)
    local query_string = read_query_files(query_files)

    query.set(lang, query_name, query_string)
  end

  local prebuild_languages = { 'typescript', 'javascript', 'tsx' }
  for _, lang in ipairs(prebuild_languages) do
    prebuild_query(lang, 'highlights')
    prebuild_query(lang, 'injections')
  end

  has_prebuilt = true
end

return TSPrebuild
