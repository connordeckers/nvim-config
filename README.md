# Neovim config

#### Patch's Neovim config, written in Lua

# Included Plugins

## Package Management

- [`wbthomason/packer.nvim`](https://github.com/wbthomason/packer.nvim)
  Used to manage plugins (modularly), and gets bootstrapped in if not already installed
  Configured to float in a panel, instead of open to the side.

- [`lewis6991/impatient.nvim`](https://github.com/lewis6991/impatient.nvim)
  Reduces load time using black magic, as far as I can tell.
  Configured to enable profiling.

## LSP

- [`nvim-treesitter/nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter)
  Enables beautiful code styling, interactions, and plenty of other goodies.

  Includes:
	- [`nvim-treesitter/playground`](https://github.com/nvim-treesitter/playground) Lets me see the current AST for the file.
	- [`nvim-treesitter/nvim-treesitter-textobjects`](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) Adds a bunch of predefined text objects to make life much nicer.
	- [`windwp/nvim-ts-autotag`](https://github.com/windwp/nvim-ts-autotag) Auto close various kinds of tags. Especially useful with HTML/JSX/etc.
	- [`theHamsta/nvim-treesitter-pairs`](https://github.com/theHamsta/nvim-treesitter-pairs) Find associated brackets using treesitter.
	- [`JoosepAlviste/nvim-ts-context-commentstring`](https://github.com/JoosepAlviste/nvim-ts-context-commentstring)
		A collection of comment strings based on the filetype of the currently selected block.
		Courtesy of treesitter, this is able to identify code blocks within other filetypes, such as nested CSS/HTML in Typescript template strings, etc.

- [`neovim/nvim-lspconfig`](https://github.com/neovim/nvim-lspconfig)
  The native LSP engine gets better, easier to interact with configurations. Practically a defacto standard.

  Also includes:

  - [`williamboman/mason.nvim`](https://github.com/williamboman/mason.nvim) A super simple interface to install LSP engines, formatters, debug adapters, linters etc.
  - [`williamboman/mason-lspconfig.nvim`](https://github.com/williamboman/mason-lspconfig.nvim) A nice way to have `Mason` and `LSPConfig` talk to each other.
  - [`jose-elias-alvarez/null-ls.nvim`](https://github.com/jose-elias-alvarez/null-ls.nvim) For all those things you wish that native LSPs could do, this does them better.
  - [`jose-elias-alvarez/typescript.nvim`](https://github.com/jose-elias-alvarez/typescript.nvim) An overridden typescript LSP, that runs faster and has better integrations
  - [`jayp0521/mason-null-ls.nvim`](https://github.com/jayp0521/mason-null-ls.nvim) A nice integration between `Mason` and `null-ls`.

- [`ray-x/lsp_signature.nvim`](https://github.com/ray-x/lsp_signature.nvim)
  Provides a lovely signature prompt when typing out a method call, similar to `coc.nvim` or VS Code.

- [`L3MON4D3/LuaSnip`](https://github.com/L3MON4D3/LuaSnip)
  A power snippet engine; a little awkward to write for, but the things it can do are exceptional.

- [`hrsh7th/nvim-cmp`](https://github.com/hrsh7th/nvim-cmp)
  Auto completion turned up to 11.

  Includes additional integrations: 
	- [`hrsh7th/cmp-nvim-lsp`](https://github.com/hrsh7th/cmp-nvim-lsp) for LSP completions 
	- [`hrsh7th/cmp-buffer`](https://github.com/hrsh7th/cmp-buffer) for completions from the buffer 
	- [`hrsh7th/cmp-path`](https://github.com/hrsh7th/cmp-path) for FS path-based completions 
	- [`hrsh7th/cmp-cmdline`](https://github.com/hrsh7th/cmp-cmdline) for command-line completions 
	- [`saadparwaiz1/cmp_luasnip`](https://github.com/saadparwaiz1/cmp_luasnip) for snippet completions

## Theme

Currently using the superb [`rose-pine/neovim`](https://github.com/rose-pine/neovim), with the `moon` variant.

## Buffer management

- [`caenrique/swap-buffers.nvim`](https://github.com/caenrique/swap-buffers.nvim) offers buffer swapping and moving around. Perfect for split-pane views.
- [`sindrets/winshift.nvim`](https://github.com/sindrets/winshift.nvim) allows windows and panes to be moved around with high fidelity.

## Diagnostics

- [`Kasama/nvim-custom-diagnostic-highlight`](https://github.com/Kasama/nvim-custom-diagnostic-highlight) to manually configure a style for unused tokens. It irritated me when they had the same style as other warnings.
- [`folke/trouble.nvim`](https://github.com/folke/trouble.nvim) for a lovely quick-fix diagnostics panel.
- [`mfussenegger/nvim-dap`](https://github.com/mfussenegger/nvim-dap) to help with debug adapter protocol integrations. As of yet, untested and unintegrated.

## UI dressing

- [`stevearc/dressing.nvim`](https://github.com/stevearc/dressing.nvim) makes the UI a lot prettier, with nice floats and borders on things.

## File explorer

- [`kyazdani42/nvim-tree.lua`](https://github.com/kyazdani42/nvim-tree.lua) A fantastic, powerful file explorer.

## Interface improvements

- [`junegunn/vim-slash`](https://github.com/junegunn/vim-slash) for easier search functionality
- [`folke/noice.nvim`](https://github.com/folke/noice.nvim) takes over management of notifications, prompts, command lines, etc.
- [`petertriho/nvim-scrollbar`](https://github.com/petertriho/nvim-scrollbar) for a nice subtle scrollbar.
- [`nvim-lualine/lualine.nvim`](https://github.com/nvim-lualine/lualine.nvim) for a beautiful powerline-style status bar.
- [`connordeckers/barbar.nvim`](https://github.com/connordeckers/barbar.nvim) for a nice buffer/tab line. Forked from [`romgrk/barbar.nvim`](https://github.com/romgrk/barbar.nvim) to make some changes, though I've forgotten what I changed.
- [`utilyre/barbecue.nvim`](https://github.com/utilyre/barbecue.nvim) and [`smiteshp/nvim-navic`](https://github.com/smiteshp/nvim-navic) to add a symbols path in the `winbar`.

## [`nvim-telescope/telescope.nvim`](https://github.com/nvim-telescope/telescope.nvim)

It's telescope. Can't live without it!

## Nice to have utilities

- [`airblade/vim-rooter`](https://github.com/airblade/vim-rooter) changes the working directory to the project root when you open a file or directory.
- [`kylechui/nvim-surround`](https://github.com/kylechui/nvim-surround) surrounds text with other text. Great for swapping braces/quotes/etc, though can replace any matching pair with the power of treesitter.
- [`ggandor/lightspeed.nvim`](https://github.com/ggandor/lightspeed.nvim) takes some getting used to, but makes navigation through code super fast.
- [`cshuaimin/ssr.nvim`](https://github.com/cshuaimin/ssr.nvim) for structural renaming. Useful for refactoring, though I haven't put it to much use yet.
- [`numtostr/comment.nvim`](https://github.com/numtostr/comment.nvim) for easy to use commenting features like inline/block comments, as well as add/remove/toggle features.
- [`lewis6991/gitsigns.nvim`](https://github.com/lewis6991/gitsigns.nvim) for showing git signs in the number column.
- [`TimUntersberger/neogit`](https://github.com/TimUntersberger/neogit) for an in-editor Git interface (note; this is really quite buggy at the moment. I've had more success just using the Git cli in another terminal window.) I look forward to seeing how this grows though!
- [`tpope/vim-obsession`](https://github.com/tpope/vim-obsession) for nice, set-and-forget session management.
- [`mbbill/undotree`](https://github.com/mbbill/undotree) for an internal undo tree; extremely useful when also using persistant undos!
- [`connordeckers/tmux-navigator.nvim`](https://github.com/connordeckers/tmux-navigator.nvim) for seamless navigation between tmux panes and neovim panes. Based on [`christoomey/vim-tmux-navigator`](https://github.com/christoomey/vim-tmux-navigator), but completely recreated in Lua.

## Misc

- Syntax highlighting for `kitty` configuration, `Caddyfile` fmt and `chezmoi` files.
- A handful of useful features under `lua/patch/utils`
- Some pretty well documented (if I do say so myself) keybindings
- A huge number of changes to the standard Vim configurations, all pretty straight forward and documented. See `lua/patch/settings.lua` for more context.
