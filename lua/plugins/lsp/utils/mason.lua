local array = require 'lsp.utils.array'
local mason_utils = require 'lsp.utils.mason-utils'

local mason = {}

---@param filter? PackageCategory The type to filter to. No filter means return all.
---@return Package[]
function mason.installed(filter)
	local pkgs = require 'mason-registry'.get_installed_packages()
	if filter == nil then return pkgs end

	return vim.tbl_filter(function(pkg) return array.has(pkg.spec.categories, filter) end, pkgs)
end

---@param packages string[] The packages to install.
---@param callback function called when all packages installed
function mason.ensure_installed(packages, callback)
	local installed = require 'mason-registry'.get_installed_package_names()
	local to_install = vim.tbl_filter(function(pkg) return not vim.tbl_contains(installed, pkg) end, packages)

	local a = require "mason-core.async"
	a.run(mason_utils.runInstalls(mason_utils.install_packages(to_install)), callback)
	-- mason_utils.waitAll(mason_utils.install_packages(to_install), blocking or false)
end

return mason
