local utils = require 'patch.utils'

vim.api.nvim_create_user_command('ReloadConfig', utils.reload_config, { nargs = 0 })
