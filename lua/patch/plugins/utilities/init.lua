local function include(package)
  return require('patch.plugins.utilities.' .. package)
end

include 'change-pwd'
include 'tmux-navigation'
include 'git-tools'
include 'editing'
include 'tasks'
include 'sessions'
-- include 'hydra'
include 'undo-tree'
