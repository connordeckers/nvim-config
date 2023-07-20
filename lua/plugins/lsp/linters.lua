-- https://github.com/mfussenegger/nvim-lint


-- local lint = {}
-- lint.config = {
-- 	cmakelint = {},
-- 	commitlint = {},
-- 	cpplint = {},
-- 	gitlint = {},
-- 	hadolint = {},
-- 	rome = {}
-- }


return {
	-- {
	-- 	'mfussenegger/nvim-lint',
	-- 	dependencies = { 'williamboman/mason.nvim' },
	-- 	config = function()
	-- 		local linter = vim.api.nvim_create_augroup('LspLinting', {})
	-- 		vim.api.nvim_clear_autocmds { group = linter }
	-- 		vim.api.nvim_create_autocmd('BufWritePost', {
	-- 			group = linter,
	-- 			callback = function()
	-- 				require 'lint'.try_lint()
	-- 			end,
	-- 		})

	-- 		local providers = vim.tbl_keys(lint.config)
	-- 		require 'lua.plugins.lsp.utils'.mason.ensure_installed(providers, function()
	-- 			require 'lint'.linters_by_ft = lint.config
	-- 		end)
	-- 	end
	-- }
}
