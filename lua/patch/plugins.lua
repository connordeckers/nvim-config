local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path }
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_was_bootstrapped = ensure_packer()

require 'patch.plugins.packer'
require 'patch.plugins.lsp'

require 'patch.plugins.ui'
require 'patch.plugins.syntax'
require 'patch.plugins.utilities'

if packer_was_bootstrapped then
  require('packer').sync()
end
