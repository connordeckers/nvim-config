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
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

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

vim.opt.foldlevel = 20
vim.opt.foldnestmax = 20
vim.opt.foldenable = false

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldcolumn = '0' -- Hide fold column until we can supress nested numbers

vim.opt.hlsearch = false
vim.opt.incsearch = true

-- The minimum spacing before the buffer will scroll
vim.opt.scrolloff = 10

-- Hide the tildes without dicking around
vim.opt.fillchars:append 'eob: '
