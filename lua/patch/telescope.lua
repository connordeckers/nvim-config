local builtins = require 'telescope.builtin'

local M = {}

function M.project_files(opts)
  local config = vim.tbl_deep_extend('force', opts or {}, {
    prompt_title = 'Project files',
    cwd = vim.fn.stdpath 'config' .. '/lua/',
  })

  builtins.find_files(config)
end

M.angular = require 'patch.modules.angular.plugin'

return M
