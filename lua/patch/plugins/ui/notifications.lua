local packer = require 'packer'
local use = packer.use

-- Notifications!
use {
  'rcarriga/nvim-notify',
  config = function()
    local banned_messages = { 'No information available', 'warning: multiple different client offset_encodings' }
    local notify = require 'notify'

    notify.setup {}
    vim.notify = function(msg, ...)
      for _, banned in ipairs(banned_messages) do
        if type(msg) == 'string' and string.match(msg, banned) then
          return
        end
      end

      notify(msg, ...)
    end
  end,
}
