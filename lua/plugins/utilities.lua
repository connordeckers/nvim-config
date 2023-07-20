local lazy_load = require('utils.import-utils').lazy_load

return {
  -- Swap buffers with each other
  {
    'caenrique/swap-buffers.nvim',
    keys = {
      { '<C-w><C-h>', lazy_load { 'swap-buffers', 'swap-buffers', 'h' } },
      { '<C-w><C-j>', lazy_load { 'swap-buffers', 'swap-buffers', 'j' } },
      { '<C-w><C-k>', lazy_load { 'swap-buffers', 'swap-buffers', 'k' } },
      { '<C-w><C-l>', lazy_load { 'swap-buffers', 'swap-buffers', 'l' } },
    },
  },

  -- Markdown preview and rendering
  { 'ellisonleao/glow.nvim', config = true, cmd = 'Glow' },

  -- Save code to a pretty screenshot!
  {
    'narutoxy/silicon.lua',
    dev = true,
    keys = {
      {
        '<Leader>bs',
        lazy_load { 'silicon', 'visualise_api' },
        mode = { 'v' },
        desc = 'Generate image of lines in a visual selection',
      },
      {
        '<Leader>bc',
        lazy_load { 'silicon', 'visualise_api', { to_clip = true } },
        mode = { 'v' },
        desc = 'Generate image of lines in a visual selection, copied to the clipboard',
      },
      {
        '<Leader>bb',
        lazy_load { 'silicon', 'visualise_api', { show_buf = true } },
        mode = { 'v', 'n' },
        desc = 'Generate image of a whole buffer, with lines in a visual selection highlighted',
      },
      {
        '<Leader>bv',
        lazy_load { 'silicon', 'visualise_api', { to_clip = true, visible = true } },
        mode = { 'n', 'v' },
        desc = 'Generate visible portion of a buffer',
      },
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      theme = 'auto',

      -- auto generate file name based on time (absolute or relative to cwd)
      output = 'SILICON_${year}-${month}-${date}_${time}.png',
      roundCorner = true,
      windowControls = true,
      windowTitle = function()
        return vim.fn.expand '%'
      end,
      lineNumber = false,
      font = 'JetBrainsMono Nerd Font',
      lineOffset = 1, -- from where to start line number
      linePad = 2, -- padding between lines
      padHoriz = 30, -- Horizontal padding
      padVert = 40, -- vertical padding
      shadowBlurRadius = 10,
      shadowColor = '#555555',
      shadowOffsetX = 8,
      shadowOffsetY = 8,
      gobble = true,
      debug = false,
    },
  },

  -- Allows the windows to be shifted with ease.
  {
    'sindrets/winshift.nvim',
    keys = {
      {
        '<leader>sw',
        function()
          require('winshift').cmd_winshift()
        end,
      },
      {
        '<leader>ss',
        function()
          require('winshift').cmd_winshift 'swap'
        end,
      },
    },
  },

  {
    'tpope/vim-fugitive',
    event = 'VeryLazy',
    keys = {
      {
        '<leader>gc',
        '<cmd>Git commit<cr>',
        desc = 'Commit currently staged files',
      },
    },
  },

  -- Diagnostics that are pretty
  {
    'folke/trouble.nvim',
    keys = {
      {
        '<leader>tr',
        function()
          require('trouble').toggle()
        end,
      },
    },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      position = 'bottom', -- position of the list can be: bottom, top, left, right
      height = 10, -- height of the trouble list when position is top or bottom
      width = 50, -- width of the list when position is left or right
      icons = true, -- use devicons for filenames
      mode = 'document_diagnostics', -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
      fold_open = '', -- icon used for open folds
      fold_closed = '', -- icon used for closed folds
      group = true, -- group results by file
      padding = true, -- add an extra new line on top of the list
      indent_lines = true, -- add an indent guide below the fold icons
      auto_open = false, -- automatically open the list when you have diagnostics
      auto_close = false, -- automatically close the list when you have no diagnostics
      auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
      auto_fold = false, -- automatically fold a file trouble list at creation
    },
  },

  -- Nvim tree
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'antosha417/nvim-lsp-file-operations',
      'echasnovski/mini.base16',
    },

    keys = {
      {
        '<leader>n',
        function()
          require('nvim-tree.api').tree.toggle()
        end,
      },
    },

    cmd = {
      'NvimTreeOpen',
      'NvimTreeClose',
      'NvimTreeToggle',
      'NvimTreeFocus',
      'NvimTreeRefresh',
      'NvimTreeFindFile',
      'NvimTreeFindFileToggle',
      'NvimTreeClipboard',
      'NvimTreeResize',
      'NvimTreeCollapse',
      'NvimTreeCollapseKeepBuffers',
    },

    opts = {
      -- Changes how files within the same directory are sorted.
      -- Can be one of `name`, `case_sensitive`, `modification_time`, `extension` or a
      -- function.
      sort_by = 'extension',

      -- Keeps the cursor on the first letter of the filename when moving in the tree.
      hijack_cursor = true,

      -- Changes the tree root directory on `DirChanged` and refreshes the tree.
      sync_root_with_cwd = true,

      -- Will change cwd of nvim-tree to that of new buffer's when opening nvim-tree.
      respect_buf_cwd = true,

      -- Hijacks new directory buffers when they are opened (`:e dir`).
      hijack_directories = { enable = true },

      -- Update the focused file on `BufEnter`, un-collapses the folders recursively
      -- until it finds the file.
      update_focused_file = {
        enable = true,

        -- Update the root directory of the tree if the file is not under current root directory.
        -- It prefers vim's cwd and `root_dirs`. Otherwise it falls back to the folder containing the file.
        -- Only relevant when `update_focused_file.enable` is `true`
        update_root = true,
      },

      -- Show LSP and COC diagnostics in the signcolumn
      diagnostics = {
        enable = true,

        -- Show diagnostic icons on parent directories.
        show_on_dirs = true,

        -- Severity for which the diagnostics will be displayed.
        severity = { min = vim.diagnostic.severity.WARN, max = vim.diagnostic.severity.ERROR },
      },

      -- Use `vim.ui.select` style prompts. Necessary when using a UI prompt decorator
      -- such as dressing.nvim or telescope-ui-select.nvim
      select_prompts = true,

      -- Hide dotfiles by default.
      filters = {
        dotfiles = true,
      },

      -- Window / buffer setup.
      view = {
        -- Resize the window on each draw based on the longest line.
        adaptive_size = true,

        -- Configuration options for floating windows
        float = { enable = false },

        mappings = {
          list = {
            -- Enter a directory/edit a file by navigating right
            { key = 'l', action = 'edit' },

            -- Collapse a directory by navigating left
            { key = 'h', action = 'close_node' },

            -- Enter a directory
            { key = 'L', action = 'cd' },
          },
        },
      },

      -- UI rendering setup
      renderer = {
        -- Appends a trailing slash to folder names.
        add_trailing = true,

        -- Compact folders that only contain a single folder into one node in the file tree.
        group_empty = true,

        -- Highlight icons and/or names for opened files.
        -- highlight_opened_files = 'all',

        -- Configuration options for tree indent markers.
        indent_markers = { enable = true },
      },

      -- Configuration for tab behaviour.
      tab = {
        -- Configuration for syncing nvim-tree across tabs.
        sync = {
          -- Opens the tree automatically when switching tabpage or opening a new
          -- tabpage if the tree was previously open.
          open = true,

          -- Closes the tree across all tabpages when the tree is closed.
          close = true,
        },
      },

      on_attach = function(bufnr)
        local api = require 'nvim-tree.api'

        local function opts(desc)
          return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- Default mappings. Feel free to modify or remove as you wish.
        --
        -- BEGIN_DEFAULT_ON_ATTACH
        vim.keymap.set('n', '<C-]>', api.tree.change_root_to_node, opts 'CD')
        vim.keymap.set('n', '<C-e>', api.node.open.replace_tree_buffer, opts 'Open: In Place')
        vim.keymap.set('n', '<C-k>', api.node.show_info_popup, opts 'Info')
        vim.keymap.set('n', '<C-r>', api.fs.rename_sub, opts 'Rename: Omit Filename')
        vim.keymap.set('n', '<C-t>', api.node.open.tab, opts 'Open: New Tab')
        vim.keymap.set('n', '<C-v>', api.node.open.vertical, opts 'Open: Vertical Split')
        vim.keymap.set('n', '<C-x>', api.node.open.horizontal, opts 'Open: Horizontal Split')
        vim.keymap.set('n', '<BS>', api.node.navigate.parent_close, opts 'Close Directory')
        vim.keymap.set('n', '<CR>', api.node.open.edit, opts 'Open')
        vim.keymap.set('n', '<Tab>', api.node.open.preview, opts 'Open Preview')
        vim.keymap.set('n', '>', api.node.navigate.sibling.next, opts 'Next Sibling')
        vim.keymap.set('n', '<', api.node.navigate.sibling.prev, opts 'Previous Sibling')
        vim.keymap.set('n', '.', api.node.run.cmd, opts 'Run Command')
        vim.keymap.set('n', '-', api.tree.change_root_to_parent, opts 'Up')
        vim.keymap.set('n', 'a', api.fs.create, opts 'Create')
        vim.keymap.set('n', 'bmv', api.marks.bulk.move, opts 'Move Bookmarked')
        vim.keymap.set('n', 'B', api.tree.toggle_no_buffer_filter, opts 'Toggle No Buffer')
        vim.keymap.set('n', 'c', api.fs.copy.node, opts 'Copy')
        vim.keymap.set('n', 'C', api.tree.toggle_git_clean_filter, opts 'Toggle Git Clean')
        vim.keymap.set('n', '[c', api.node.navigate.git.prev, opts 'Prev Git')
        vim.keymap.set('n', ']c', api.node.navigate.git.next, opts 'Next Git')
        vim.keymap.set('n', 'd', api.fs.remove, opts 'Delete')
        vim.keymap.set('n', 'D', api.fs.trash, opts 'Trash')
        vim.keymap.set('n', 'E', api.tree.expand_all, opts 'Expand All')
        vim.keymap.set('n', 'e', api.fs.rename_basename, opts 'Rename: Basename')
        vim.keymap.set('n', ']e', api.node.navigate.diagnostics.next, opts 'Next Diagnostic')
        vim.keymap.set('n', '[e', api.node.navigate.diagnostics.prev, opts 'Prev Diagnostic')
        vim.keymap.set('n', 'F', api.live_filter.clear, opts 'Clean Filter')
        vim.keymap.set('n', 'f', api.live_filter.start, opts 'Filter')
        vim.keymap.set('n', 'g?', api.tree.toggle_help, opts 'Help')
        vim.keymap.set('n', 'gy', api.fs.copy.absolute_path, opts 'Copy Absolute Path')
        vim.keymap.set('n', 'H', api.tree.toggle_hidden_filter, opts 'Toggle Dotfiles')
        vim.keymap.set('n', 'I', api.tree.toggle_gitignore_filter, opts 'Toggle Git Ignore')
        vim.keymap.set('n', 'J', api.node.navigate.sibling.last, opts 'Last Sibling')
        vim.keymap.set('n', 'K', api.node.navigate.sibling.first, opts 'First Sibling')
        vim.keymap.set('n', 'm', api.marks.toggle, opts 'Toggle Bookmark')
        vim.keymap.set('n', 'o', api.node.open.edit, opts 'Open')
        vim.keymap.set('n', 'O', api.node.open.no_window_picker, opts 'Open: No Window Picker')
        vim.keymap.set('n', 'p', api.fs.paste, opts 'Paste')
        vim.keymap.set('n', 'P', api.node.navigate.parent, opts 'Parent Directory')
        vim.keymap.set('n', 'q', api.tree.close, opts 'Close')
        vim.keymap.set('n', 'r', api.fs.rename, opts 'Rename')
        vim.keymap.set('n', 'R', api.tree.reload, opts 'Refresh')
        vim.keymap.set('n', 's', api.node.run.system, opts 'Run System')
        vim.keymap.set('n', 'S', api.tree.search_node, opts 'Search')
        vim.keymap.set('n', 'U', api.tree.toggle_custom_filter, opts 'Toggle Hidden')
        vim.keymap.set('n', 'W', api.tree.collapse_all, opts 'Collapse')
        vim.keymap.set('n', 'x', api.fs.cut, opts 'Cut')
        vim.keymap.set('n', 'y', api.fs.copy.filename, opts 'Copy Name')
        vim.keymap.set('n', 'Y', api.fs.copy.relative_path, opts 'Copy Relative Path')
        vim.keymap.set('n', '<2-LeftMouse>', api.node.open.edit, opts 'Open')
        vim.keymap.set('n', '<2-RightMouse>', api.tree.change_root_to_node, opts 'CD')
        -- END_DEFAULT_ON_ATTACH

        -- Mappings migrated from view.mappings.list
        --
        -- You will need to insert "your code goes here" for any mappings with a custom action_cb
        vim.keymap.set('n', 'l', api.node.open.edit, opts 'Open')
        vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts 'Close Directory')
        vim.keymap.set('n', 'L', api.tree.change_root_to_node, opts 'CD')
      end,
    },
  },

  -- Adds task management
  {
    'stevearc/overseer.nvim',
    keys = {
      {
        '<leader>ot',
        function()
          require('overseer').toggle { enter = false }
        end,
      },
    },
    opts = {
      -- Default task strategy
      strategy = 'terminal',
      -- Template modules to load
      templates = { 'builtin' },
      -- When true, tries to detect a green color from your colorscheme to use for success highlight
      auto_detect_success_color = true,
      -- Patch nvim-dap to support preLaunchTask and postDebugTask
      dap = true,
      -- Configure the task list
      task_list = {
        -- Default detail level for tasks. Can be 1-3.
        default_detail = 1,
        -- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        -- min_width and max_width can be a single value or a list of mixed integer/float types.
        -- max_width = {100, 0.2} means "the lesser of 100 columns or 20% of total"
        max_width = { 100, 0.2 },
        -- min_width = {40, 0.1} means "the greater of 40 columns or 10% of total"
        min_width = { 40, 0.1 },
        -- optionally define an integer/float for the exact width of the task list
        width = nil,
        max_height = { 20, 0.1 },
        min_height = 8,
        height = nil,
        -- String that separates tasks
        separator = '────────────────────────────────────────',
        -- Default direction. Can be "left", "right", or "bottom"
        direction = 'bottom',
        -- Set keymap to false to remove default behavior
        -- You can add custom keymaps here as well (anything vim.keymap.set accepts)
        bindings = {
          ['?'] = 'ShowHelp',
          ['<CR>'] = 'RunAction',
          ['<C-e>'] = 'Edit',
          ['o'] = 'Open',
          ['<C-v>'] = 'OpenVsplit',
          ['<C-s>'] = 'OpenSplit',
          ['<C-f>'] = 'OpenFloat',
          ['<C-q>'] = 'OpenQuickFix',
          ['p'] = 'TogglePreview',
          ['+'] = 'IncreaseDetail',
          ['-'] = 'DecreaseDetail',
          ['L'] = 'IncreaseAllDetail',
          ['H'] = 'DecreaseAllDetail',
          ['['] = 'DecreaseWidth',
          [']'] = 'IncreaseWidth',
          ['{'] = 'PrevTask',
          ['}'] = 'NextTask',
        },
      },
      -- See :help overseer-actions
      actions = {},
      -- Configure the floating window used for task templates that require input
      -- and the floating window used for editing tasks
      form = {
        border = 'rounded',
        zindex = 40,
        -- Dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        -- min_X and max_X can be a single value or a list of mixed integer/float types.
        min_width = 80,
        max_width = 0.9,
        width = nil,
        min_height = 10,
        max_height = 0.9,
        height = nil,
        -- Set any window options here (e.g. winhighlight)
        win_opts = {
          winblend = 0,
        },
      },
      task_launcher = {
        -- Set keymap to false to remove default behavior
        -- You can add custom keymaps here as well (anything vim.keymap.set accepts)
        bindings = {
          i = {
            ['<C-s>'] = 'Submit',
            ['<C-c>'] = 'Cancel',
          },
          n = {
            ['<CR>'] = 'Submit',
            ['<C-s>'] = 'Submit',
            ['q'] = 'Cancel',
            ['?'] = 'ShowHelp',
          },
        },
      },
      task_editor = {
        -- Set keymap to false to remove default behavior
        -- You can add custom keymaps here as well (anything vim.keymap.set accepts)
        bindings = {
          i = {
            ['<CR>'] = 'NextOrSubmit',
            ['<C-s>'] = 'Submit',
            ['<Tab>'] = 'Next',
            ['<S-Tab>'] = 'Prev',
            ['<C-c>'] = 'Cancel',
          },
          n = {
            ['<CR>'] = 'NextOrSubmit',
            ['<C-s>'] = 'Submit',
            ['<Tab>'] = 'Next',
            ['<S-Tab>'] = 'Prev',
            ['q'] = 'Cancel',
            ['?'] = 'ShowHelp',
          },
        },
      },
      -- Configure the floating window used for confirmation prompts
      confirm = {
        border = 'rounded',
        zindex = 40,
        -- Dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        -- min_X and max_X can be a single value or a list of mixed integer/float types.
        min_width = 20,
        max_width = 0.5,
        width = nil,
        min_height = 6,
        max_height = 0.9,
        height = nil,
        -- Set any window options here (e.g. winhighlight)
        win_opts = {
          winblend = 0,
        },
      },
      -- Configuration for task floating windows
      task_win = {
        -- How much space to leave around the floating window
        padding = 2,
        border = 'rounded',
        -- Set any window options here (e.g. winhighlight)
        win_opts = {
          winblend = 0,
        },
      },
      -- Aliases for bundles of components. Redefine the builtins, or create your own.
      component_aliases = {
        -- Most tasks are initialized with the default components
        default = {
          { 'display_duration', detail_level = 2 },
          'on_output_summarize',
          'on_exit_set_status',
          'on_complete_notify',
          'on_complete_dispose',
        },
        -- Tasks from tasks.json use these components
        default_vscode = {
          'default',
          'on_result_diagnostics',
          'on_result_diagnostics_quickfix',
        },
      },
      bundles = {
        -- When saving a bundle with OverseerSaveBundle or save_task_bundle(), filter the tasks with
        -- these options (passed to list_tasks())
        save_task_opts = { bundleable = true },
      },
      -- A list of components to preload on setup.
      -- Only matters if you want them to show up in the task editor.
      preload_components = {},
      -- Controls when the parameter prompt is shown when running a template
      --   always    Show when template has any params
      --   missing   Show when template has any params not explicitly passed in
      --   allow     Only show when a required param is missing
      --   avoid     Only show when a required param with no default value is missing
      --   never     Never show prompt (error if required param missing)
      default_template_prompt = 'allow',
      -- For template providers, how long to wait (in ms) before timing out.
      -- Set to 0 to disable timeouts.
      template_timeout = 3000,
      -- Cache template provider results if the provider takes longer than this to run.
      -- Time is in ms. Set to 0 to disable caching.
      template_cache_threshold = 100,
      -- Configure where the logs go and what level to use
      -- Types are "echo", "notify", and "file"
      log = {
        {
          type = 'echo',
          level = vim.log.levels.WARN,
        },
        {
          type = 'file',
          filename = 'overseer.log',
          level = vim.log.levels.WARN,
        },
      },
    },
  },

  -- Tmux pane navigation assistant
  -- {
  --   'connordeckers/tmux-navigator.nvim',
  --
  --   keys = {
  --     { '<C-h>', navigate 'left', desc = 'Move to the panel on the left' }, -- Move left
  --     { '<C-j>', navigate 'down', desc = 'Move to the panel below' }, -- Move down
  --     { '<C-k>', navigate 'up', desc = 'Move to the panel above' }, -- Move up
  --     { '<C-l>', navigate 'right', desc = 'Move to the panel on the right' }, -- Move right
  --   },
  --
  --   opts = {
  --     enabled = true,
  --     DisableMapping = true,
  --     DisableWhenZoomed = true,
  --   },
  -- },
  {
    'mrjones2014/smart-splits.nvim',
    lazy = false,
    keys = {
      -- recommended mappings
      -- resizing splits
      -- these keymaps will also accept a range,
      -- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
      {
        '<A-h>',
        function()
          require('smart-splits').resize_left()
        end,
      },
      {
        '<A-j>',
        function()
          require('smart-splits').resize_down()
        end,
      },
      {
        '<A-k>',
        function()
          require('smart-splits').resize_up()
        end,
      },
      {
        '<A-l>',
        function()
          require('smart-splits').resize_right()
        end,
      },
      -- moving between splits
      {
        '<C-h>',
        function()
          require('smart-splits').move_cursor_left()
        end,
      },
      {
        '<C-j>',
        function()
          require('smart-splits').move_cursor_down()
        end,
      },
      {
        '<C-k>',
        function()
          require('smart-splits').move_cursor_up()
        end,
      },
      {
        '<C-l>',
        function()
          require('smart-splits').move_cursor_right()
        end,
      },
      -- swapping buffers between windows
      -- {
      --   '<leader><leader>h',
      --   function()
      --     require('smart-splits').swap_buf_left()
      --   end,
      -- },
      -- {
      --   '<leader><leader>j',
      --   function()
      --     require('smart-splits').swap_buf_down()
      --   end,
      -- },
      -- {
      --   '<leader><leader>k',
      --   function()
      --     require('smart-splits').swap_buf_up()
      --   end,
      -- },
      -- {
      --   '<leader><leader>l',
      --   function()
      --     require('smart-splits').swap_buf_right()
      --   end,
      -- },
    },
  },

  -- Rooter changes the working directory to the project root when you open a file or directory.
  -- 'airblade/vim-rooter',
  {
    'ahmedkhalf/project.nvim',
    main = 'project_nvim',
    event = 'VeryLazy',
    opts = {
      -- Manual mode doesn't automatically change your root directory, so you have
      -- the option to manually do so using `:ProjectRoot` command.
      manual_mode = false,

      -- Methods of detecting the root directory. **"lsp"** uses the native neovim
      -- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
      -- order matters: if one is not detected, the other is used as fallback. You
      -- can also delete or rearangne the detection methods.
      detection_methods = { 'lsp', 'pattern' },

      -- All the patterns used to detect root dir, when **"pattern"** is in
      -- detection_methods
      patterns = { '.projectroot', '.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', 'package.json' },

      -- Table of lsp clients to ignore by name
      -- eg: { "efm", ... }
      ignore_lsp = {},

      -- Don't calculate root dir on specific directories
      -- Ex: { "~/.cargo/*", ... }
      exclude_dirs = {},

      -- Show hidden files in telescope
      show_hidden = false,

      -- When set to false, you will get a message when project.nvim changes your
      -- directory.
      silent_chdir = true,

      -- What scope to change the directory, valid options are
      -- * global (default)
      -- * tab
      -- * win
      scope_chdir = 'global',

      -- Path where project.nvim will store the project history for use in
      -- telescope
      datapath = vim.fn.stdpath 'data',
    },
  },
  -- Some nice git features
  {
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    opts = {
      signcolumn = false,
      numhl = true,
      linehl = false,
      word_diff = false,
      watch_gitdir = { interval = 1000, follow_files = true },
      attach_to_untracked = true,
      current_line_blame = true,
      current_line_blame_opts = { virt_text = true, virt_text_pos = 'eol', delay = 500 },
      current_line_blame_formatter_opts = { relative_time = false },
      current_line_blame_formatter = '<summary> (<author> | <author_time:%Y-%m-%d>)',
      sign_priority = 6,
      update_debounce = 150,
      status_formatter = nil,
      max_file_length = 40000,
      preview_config = {
        border = 'single',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1,
      },
    },
  },

  {
    'sindrets/diffview.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },

  -- Surround text with other text. Neat!
  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    opts = {},
  },

  -- Lightspeed navigation, but better!
  {
    'ggandor/leap.nvim',
    event = 'BufRead',
    dependencies = {
      'tpope/vim-repeat',
      { 'ggandor/flit.nvim', config = true },
      {
        {
          'ggandor/leap-spooky.nvim',
          opts = {
            affixes = {
              -- These will generate mappings for all native text objects, like:
              -- (ir|ar|iR|aR|im|am|iM|aM){obj}.
              -- Special line objects will also be added, by repeating the affixes.
              -- E.g. `yrr<leap>` and `ymm<leap>` will yank a line in the current
              -- window.
              -- r - cursor doesn't move to the targeted position
              -- m - cursor moves to the targeted position
              -- You can also use 'rest' & 'move' as mnemonics.
              remote = { window = 'r', cross_window = 'R' },
              magnetic = { window = 'm', cross_window = 'M' },
            },
            -- If this option is set to true, the yanked text will automatically be pasted
            -- at the cursor position if the unnamed register is in use.
            paste_on_remote_yank = false,
          },
        },
      },
    },
    config = function()
      require('leap').add_default_mappings()
    end,
  },

  -- Better, easier, structural renaming.
  {
    'cshuaimin/ssr.nvim',
    keys = {
      {
        '<leader>sr',
        mode = { 'n', 'x' },
        function()
          require('ssr').open()
        end,
      },
    },
    opts = {
      min_width = 50,
      min_height = 5,
      keymaps = {
        close = 'q',
        next_match = 'n',
        prev_match = 'N',
        replace_all = '<leader><cr>',
      },
    },
  },

  -- Commenting tool
  {
    'numtostr/comment.nvim',
    dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
    keys = {
      -- Toggle current line (linewise) using C-i
      {
        '<leader>ci',
        function()
          require('Comment.api').toggle.linewise.current()
        end,
      },
      {
        '<leader>ci',
        function()
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<ESC>', true, false, true), 'nx', false)
          require('Comment.api').toggle.linewise(vim.fn.visualmode())
        end,
        mode = 'x',
      },

      -- Toggle current line (blockwise) using C-b
      {
        '<leader>cb',
        function()
          require('Comment.api').toggle.blockwise.current()
        end,
      },

      {
        '<leader>cb',
        function()
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<ESC>', true, false, true), 'nx', false)
          require('Comment.api').toggle.blockwise(vim.fn.visualmode())
        end,
        mode = 'x',
      },

      -- Toggle lines (linewise) with dot-repeat support
      -- Example: <leader>gc3j will comment 4 lines
      {
        '<leader>gc',
        function()
          require('Comment.api').call('toggle.linewise', 'g@')
        end,
        expr = true,
      },

      -- Toggle lines (blockwise) with dot-repeat support
      -- Example: <leader>gb3j will comment 4 lines
      {
        '<leader>gb',
        function()
          require('Comment.api').call('toggle.blockwise', 'g@')
        end,
        expr = true,
      },
    },
    opts = {
      ---Add a space b/w comment and the line
      ---@type boolean|fun():boolean
      padding = true,

      ---Whether the cursor should stay at its position
      ---NOTE: This only affects NORMAL mode mappings and doesn't work with dot-repeat
      ---@type boolean
      sticky = true,

      ---Lines to be ignored while comment/uncomment.
      ---Could be a regex string or a function that returns a regex string.
      ---Example: Use '^$' to ignore empty lines
      ---@type string|fun():string
      -- ignore = nil,
      ignore = '^$',

      ---Create basic (operator-pending) and extended mappings for NORMAL + VISUAL mode
      ---NOTE: If `mappings = false` then the plugin won't create any mappings
      ---@type boolean|table
      mappings = {
        basic = false,
        extra = false,
      },

      ---Pre-hook, called before commenting the line
      ---@type fun(ctx:CommentCtx):any|nil
      -- pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),

      ---Post-hook, called after commenting is done
      ---@type fun(ctx: CommentCtx)
      -- post_hook = nil,
    },
  },

  -- Continuously updated session files
  { 'tpope/vim-obsession', cmd = 'Obsess' },

  -- {
  --   'mbbill/undotree',
  --   cmd = { 'UndotreeToggle' },
  --   keys = { { '<leader>u', '<cmd>UndotreeToggle<cr>' } },
  -- },

  {
    'akinsho/toggleterm.nvim',
    keys = { { '<leader>tt' } },
    opts = {
      open_mapping = [[<leader>tt]],
      hide_numbers = true, -- hide the number column in toggleterm buffers
      start_in_insert = true,
      insert_mappings = false, -- whether or not the open mapping applies in insert mode
      terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
      persist_size = true,
      persist_mode = true, -- if set to true (default) the previous terminal mode will be remembered
      direction = 'float',
      close_on_exit = true, -- close the terminal window when the process exits
      -- Change the default shell. Can be a string or a function returning a string
      shell = vim.o.shell,
      auto_scroll = true, -- automatically scroll to the bottom on terminal output
      -- This field is only relevant if direction is set to 'float'
      float_opts = {
        -- The border key is *almost* the same as 'nvim_open_win'
        -- see :h nvim_open_win for details on borders however
        -- the 'curved' border is a custom border type
        -- not natively supported but implemented in this plugin.
        border = 'single',
        -- like `size`, width and height can be a number or function which is passed the current terminal
        winblend = 0,
      },
    },
  },
}
