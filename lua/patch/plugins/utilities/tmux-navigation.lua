local packer = require 'packer'
local use = packer.use

-- Sync navigation with tmux
use {
	 'connordeckers/tmux-navigator.nvim',
	 config = function()
		local navigator = require 'tmux-navigator'
		navigator.setup {
			enabled = true,
			DisableMapping = true,
		}
	 end
}
