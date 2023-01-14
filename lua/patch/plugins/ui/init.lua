local function include(package)
  return require('patch.plugins.ui.' .. package)
end

include 'themes'
include 'buffer-management'
include 'diagnostics'
include 'filetree'
-- include 'notifications'
include 'scrollbar'
include 'statusline'
include 'telescope'
include 'noice'
