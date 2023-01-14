vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.termguicolors = true

vim.cmd [[ highlight clear SignColumn ]]
vim.cmd [[ highlight EndOfBuffer guifg=bg ]]
vim.cmd [[ highlight NvimTreeWinSeparator guifg=bg ]]
vim.cmd [[ highlight NvimTreeStatusLine guibg=bg ]]

-- TextEdit might fail if hidden is not set.
vim.opt.hidden = true

-- Some servers have issues with backup files, see #649.
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- Give more space for displaying messages.
vim.opt.cmdheight = 1

-- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
-- delays and poor user experience.
vim.opt.updatetime = 300

-- Don't pass messages to |ins-completion-menu|.
vim.opt.shortmess:append { c = true }

-- Set tabstop size
local tabsize = 2
vim.opt.tabstop = tabsize
vim.opt.shiftwidth = tabsize

-- Highlight yanked text for 250ms
vim.api.nvim_create_autocmd({ 'TextYankPost' }, {
  pattern = '*',
  callback = function()
    vim.highlight.on_yank {
      higroup = (vim.fn['hlexists'] 'HighlightedyankRegion' > 0 and 'HighlightedyankRegion' or 'IncSearch'),
      timeout = 250,
    }
  end,
})

--Save undo history
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath 'data' .. '/undodir'

--Case insensitive searching UNLESS /C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

--Decrease update time
vim.opt.updatetime = 500
vim.opt.timeoutlen = 500

-- Yank to/from the system clipboard by default
vim.opt.clipboard = 'unnamedplus'

-- Use more natural splitting
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Show signs in the numbers column, and show the numbers column by default
vim.opt.signcolumn = 'number'
vim.opt.number = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

-- The minimum spacing before the buffer will scroll
vim.opt.scrolloff = 10

-- Show strikethrough and undercurl correctly in some particular terminal environments
vim.cmd [[
	if &term =~ 'xterm\|kitty\|alacritty\|tmux'
			let &t_Ts = "\e[9m"   " Strikethrough
			let &t_Te = "\e[29m"
			let &t_Cs = "\e[4:3m" " Undercurl
			let &t_Ce = "\e[4:0m"
	endif
]]

-- Hide the tildes without dicking around
vim.opt.fillchars:append 'eob: '
