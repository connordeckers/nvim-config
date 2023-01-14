local h = require 'null-ls.helpers'
local methods = require 'null-ls.methods'
local ts = require 'typescript'

local CODE_ACTION = methods.internal.CODE_ACTION

local function camelCaseToString(str, sentenceCase)
  sentenceCase = sentenceCase or false
  if not str then
    return ''
  end

  local s = str:gsub('%u', ' %1')
  if sentenceCase then
    s = s:gsub('%u', string.lower)
  end

  return s:gsub('^%l', string.upper)
end

return h.make_builtin {
  name = 'typescript-actions',
  method = CODE_ACTION,
  filetypes = { 'typescript', 'typescriptreact' },
  generator = {
    fn = function(params)
      local actions = {}

      for action, fn in pairs(ts.actions) do
        table.insert(actions, {
          title = camelCaseToString(action, true),
          action = function()
            fn(params)
          end,
        })
      end

      return actions
    end,
  },
}
