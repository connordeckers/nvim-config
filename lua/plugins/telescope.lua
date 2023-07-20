local function builtin(method, opts)
  return function()
    require('telescope.builtin')[method](opts)
  end
end

local function extension(method, opts)
  return function()
    require('telescope').extensions[method][method](opts)
  end
end

---------------
-- Telescope --
---------------
local fzf_native = {
  'nvim-telescope/telescope-fzf-native.nvim',
  build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
}

local keys = {
  {
    '<leader>tb',
    builtin 'builtin',
    -- function()
    --   extension('find_pickers', require('telescope.themes').get_dropdown {})()
    -- end,
    -- desc = 'Show all telescope builtins and extensions',
  },

  { '<leader>tf', builtin 'find_files', desc = 'Show file finder' },
  { '<leader>th', builtin('find_files', { hidden = true }) },
  { '<leader>to', builtin 'oldfiles' },

  { '<leader>tg', builtin 'live_grep', desc = 'Show grep finder' },

  { '<leader>ts', builtin('grep_string', { shorten_path = true, word_match = '-w', only_sort_text = true, search = '' }), desc = 'Show fuzzy text search' },

  -- Show notifications
  -- { '<leader>tn', function() require('telescope').extensions.notify.notify(require('telescope.themes').get_dropdown {}) end, },

  { '<leader>ff', builtin 'grep_string', desc = 'Grep current string under cursor within workspace' },

  { '<leader>tj', builtin 'jumplist', desc = 'Show jumplist' },

  { '"', builtin 'registers', desc = 'List registers' },

  { '<C-p>', builtin 'buffers', desc = 'List open buffers' },

  { '<leader>tp', extension 'projects', desc = 'Show project finder' },

  -- { '<leader>b', extension 'file_browser', desc = 'Show file browser' },

  { '<leader>tl', extension 'termfinder', desc = 'Show project finder' },

  { '<leader>dg', builtin 'diagnostics', desc = 'Show diagnostics' },
  { '<leader>lq', builtin 'quickfix' },
  { '<leader>gs', builtin 'git_status' },
  { '<leader>lr', builtin 'lsp_references', desc = 'Lists LSP references for word under the cursor' },
  { '<leader>lci', builtin 'lsp_incoming_calls', desc = 'Lists LSP incoming calls for word under the cursor' },
  { '<leader>lco', builtin 'lsp_outgoing_calls', desc = 'Lists LSP outgoing calls for word under the cursor' },
  { '<leader>ls', builtin 'lsp_document_symbols', desc = 'Lists LSP document symbols in the current buffer' },
  { '<leader>ws', builtin 'lsp_dynamic_workspace_symbols', desc = 'Dynamically Lists LSP for all workspace symbols' },
  {
    '<leader>li',
    builtin 'lsp_implementations',
    desc = "Goto the implementation of the word under the cursor if there's only one, otherwise show all options in Telescope",
  },
  {
    '<leader>ld',
    builtin 'lsp_definitions',
    desc = "Goto the definition of the word under the cursor, if there's only one, otherwise show all options in Telescope",
  },
  {
    '<leader>lt',
    builtin 'lsp_type_definitions',
    desc = "Goto the definition of the type of the word under the cursor, if there's only one, otherwise show all options in Telescope",
  },

  {
    '<leader>u',
    extension 'undo',
  },
}

return {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'nvim-telescope/telescope-symbols.nvim',
      'BurntSushi/ripgrep',
      'nvim-treesitter/nvim-treesitter',
      fzf_native,
      'nvim-telescope/telescope-file-browser.nvim',
      'ahmedkhalf/project.nvim',
      { 'tknightz/telescope-termfinder.nvim', dependencies = { 'akinsho/toggleterm.nvim' } },

      'keyvchan/telescope-find-pickers.nvim',
      'cljoly/telescope-repo.nvim',
      'chip/telescope-software-licenses.nvim',
      'debugloop/telescope-undo.nvim',
      { 'nvim-telescope/telescope-dap.nvim', dependencies = { 'mfussenegger/nvim-dap' } },
    },
    keys = keys,
    opts = {
      defaults = { mappings = { i = { ['<C-h>'] = 'which_key' } }, initial_mode = 'normal' },
      pickers = {
        find_files = { find_command = { 'fd', '--type', 'f', '--strip-cwd-prefix' }, initial_mode = 'insert' },
        live_grep = { initial_mode = 'insert' },
        diagnostics = { theme = 'dropdown' },
        jumplist = { theme = 'dropdown' },
        registers = { theme = 'dropdown' },
        buffers = { theme = 'dropdown' },
        -- quickfix = { theme = 'dropdown' },

        -- Lists LSP references for word under the cursor
        lsp_references = { theme = 'dropdown' },

        -- Lists LSP incoming calls for word under the cursor
        lsp_incoming_calls = { theme = 'dropdown' },

        -- Lists LSP outgoing calls for word under the cursor
        lsp_outgoing_calls = { theme = 'dropdown' },

        -- Lists LSP document symbols in the current buffer
        lsp_document_symbols = { theme = 'dropdown' },

        -- Lists LSP document symbols in the current workspace
        lsp_workspace_symbols = { theme = 'dropdown' },

        -- Dynamically Lists LSP for all workspace symbols
        lsp_dynamic_workspace_symbols = { theme = 'dropdown' },

        -- Goto the implementation of the word under the cursor if there's only one, otherwise show all options in Telescope
        lsp_implementations = { theme = 'dropdown' },

        -- Goto the definition of the word under the cursor, if there's only one, otherwise show all options in Telescope
        lsp_definitions = { theme = 'dropdown' },

        -- Goto the definition of the type of the word under the cursor, if there's only one, otherwise show all options in Telescope
        lsp_type_definitions = { theme = 'dropdown' },
      },
      extensions = {
        undo = {
          side_by_side = true,
          layout_strategy = 'vertical',
          layout_config = {
            preview_height = 0.8,
          },
        },
        find_pickers = {
          initial_mode = 'insert',
        },
        http = {
          -- How the mozilla url is opened. By default will be configured based on OS:
          open_url = 'xdg-open %s', -- UNIX
          -- open_url = 'open %s' -- OSX
          -- open_url = 'start %s' -- Windows
        },
        repo = {
          list = {
            fd_opts = { '--no-ignore-vcs' },
            search_dirs = { '~' },
          },
        },
        fzf = {
          -- false will only do exact matching
          fuzzy = true,

          -- override the generic sorter
          override_generic_sorter = true,

          -- override the file sorter
          override_file_sorter = true,

          -- "smart_case" or "ignore_case" or "respect_case"
          case_mode = 'smart_case',
        },
        file_browser = {
          theme = 'ivy',
          hijack_netrw = true,
        },
      },
    },

    config = function(_, opts)
      require('telescope').setup(opts)
      require('telescope').load_extension 'fzf'
      require('telescope').load_extension 'projects'
      require('telescope').load_extension 'file_browser'
      require('telescope').load_extension 'termfinder'
      require('telescope').load_extension 'repo'
      require('telescope').load_extension 'software-licenses'
      require('telescope').load_extension 'undo'
      require('telescope').load_extension 'find_pickers'
      require('telescope').load_extension 'dap'
    end,
  },
}
