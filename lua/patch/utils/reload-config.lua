for k, v in pairs(package.loaded) do
  package.loaded[k] = nil
end

require 'patch'
require('packer').compile()
