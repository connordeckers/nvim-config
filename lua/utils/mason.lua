local array = require 'utils.array'
local mason_utils = { }

---@param pkg string
function mason_utils.validate(pkg)
	local Package = require "mason-core.package"
	local registry = require "mason-registry"
	local package_name = Package.Parse(pkg)
	local ok, p = pcall(registry.get_package, package_name)
	return ok and p or nil
end

---@param handles InstallHandle[]
function mason_utils.runInstalls(handles)
	local _ = require "mason-core.functional"
	local a = require "mason-core.async"
	local Optional = require "mason-core.optional"

	_.each(
	---@param handle InstallHandle
		function(handle)
			handle:on("stdout", vim.schedule_wrap(vim.api.nvim_out_write))
			handle:on("stderr", vim.schedule_wrap(vim.api.nvim_err_write))
		end,
		handles
	)

	local function do_tasks()
		a.wait_all(_.map(
		---@param handle InstallHandle
			function(handle)
				return function()
					a.wait(function(resolve)
						if handle:is_closed() then
							resolve()
						else
							handle:once("closed", resolve)
						end
					end)
				end
			end,
			handles
		))
		local failed_packages = _.filter_map(function(handle)
			-- TODO: The outcome of a package installation is currently not captured in the handle, but is instead
			-- internalized in the Package instance itself. Change this to assert on the handle state when it's
			-- available.
			if not handle.package:is_installed() then
				return Optional.of(handle.package.name)
			else
				return Optional.empty()
			end
		end, handles)

		if _.length(failed_packages) > 0 then
			a.wait(vim.schedule) -- wait for scheduler for logs to finalize
			a.wait(vim.schedule) -- logs have been written
			vim.api.nvim_err_writeln ""
			vim.api.nvim_err_writeln(
				("The following packages failed to install: %s"):format(_.join(", ", failed_packages))
			)
		end
	end

	return do_tasks
end

---@param package_specifiers string[]
---@param opts? PackageInstallOpts
function mason_utils.install_packages(package_specifiers, opts)
	opts = opts or {}
	local options = {
		debug = opts.debug,
		force = opts.force,
		strict = opts.strict,
		target = opts.target,
	}

	require "mason-registry".refresh()
	local valid_packages = vim.tbl_map(mason_utils.validate, package_specifiers)
	if #valid_packages ~= #package_specifiers then
		return {}
	end

	return vim.tbl_map(function(pkg) return pkg:install(options) end, valid_packages)
end


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

mason.utils = mason_utils

return mason
