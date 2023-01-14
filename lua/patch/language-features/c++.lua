local notify = require 'notify'.notify
local promise = require 'patch.utils.async'
local string_utils = require 'patch.utils.string-utils'

table.filter = require 'patch.utils.filter-list'.filter

M = {}
M.compile = function(complete_callback)
	local lines = {""}
	local makeprg = vim.o.makeprg
	if not makeprg then return end

	local cmd = vim.fn.expandcmd(makeprg)
	local starttime = vim.loop.now()

	local function on_event(job_id, data, event)
		if event == "stdout" or event == "stderr" then
			if data then for _,v in ipairs(data) do table.insert(lines, v) end end
		end

		if event == "exit" then
			vim.fn.setqflist({}, "r", {
				title = cmd,
				lines = lines,
				efm = vim.o.errorformat
			})
			vim.api.nvim_command("doautocmd QuickFixCmdPost")

			local endtime = vim.loop.now()
			local time_taken = endtime - starttime

			local complete_time = ""

			if time_taken < 1000 then
				complete_time = string.format ("\nCompleted in %dms", time_taken)
			else
				complete_time = string.format ("\nCompleted in %1.3f seconds", time_taken / 1000)
			end

			table.insert(lines, complete_time)

			if complete_callback
				then complete_callback(data, lines)
				else
					if data ~= 0 then
						local msg = table.filter(lines, function(v) return string.len(v) > 0 end)
						notify(table.concat(msg, "\n"), "error", { title = ":: Build error ::" })
					else
						notify("Build successful!" .. complete_time, nil, { title = ":: Build success ::" })
					end
			end
		end
	end

	local job_id = vim.fn.jobstart(
		cmd,
		{
			on_stderr = on_event,
			on_stdout = on_event,
			on_exit = on_event,
			stdout_buffered = true,
			stderr_buffered = true
		}
	)
end

M.run = function()
	local path = vim.fn.expand('%:r')
	local name = vim.fn.expand('%:t:r')
	local output = vim.fn.system(path)

	local exitcode = vim.v.shell_error
	local msg_type = exitcode == 0 and "info" or "error"

	notify(string_utils.trim(output), msg_type, {
		title = "Runtime output: " .. name .. " [code: " .. exitcode .. "]",
		timeout = 5000
	})
end

local compile = promise.wrap(M.compile)
M.build_and_run = promise.sync(function()
	local exit_code, lines = promise.wait(compile())
	local msg = table.filter(lines, function(v) return string.len(string_utils.trim(v)) end)

	if exit_code == 0
		then M.run()
		else notify(table.concat(msg, "\n"), "error", { title = ":: Build error ::" })
	end
end)

return M
