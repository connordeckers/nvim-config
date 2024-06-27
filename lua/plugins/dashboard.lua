return {
  -- {
  --   'CWood-sdf/spaceport.nvim',
  --   lazy = false, -- load spaceport immediately
  --   opts = {
  --     -- This prevents the same directory from being repeated multiple times in the recents section
  --     -- For example, I have replaceDirs set to { {"~/projects", "_" } } so that ~/projects is not repeated a ton
  --     -- Note every element is applied to the directory in order,
  --     --   so if you have { {"~/projects", "_"} } and you also want to replace
  --     --   ~/projects/foo with @, then you would need
  --     --   { {"~/projects/foo", "@"}, {"~/projects", "_"} }
  --     --   or { {"~/projects", "_"}, {"_/foo", "@"} }
  --     -- replaceDirs = {},

  --     -- turn /home/user/ into ~/ (also works on windows for C:\Users\user\)
  --     -- replaceHome = true,

  --     -- -- What to do when entering a directory, personally I use "Oil .", but Ex is preinstalled with neovim
  --     projectEntry = 'Oil',

  --     -- -- The farthest back in time that directories should be shown
  --     -- -- I personally use "yesterday" so that there aren't millions of directories on the screen.
  --     -- -- the possible values are: "pin", "today", "yesterday", "pastWeek", "pastMonth", and "later"
  --     -- lastViewTime = 'pastMonth',

  --     -- -- The maximum number of directories to show in the recents section (0 means show all of them)
  --     -- maxRecentFiles = 20,

  --     -- -- The sections to show on the screen (see `Customization` for more info)
  --     -- sections = {
  --     --   '_global_remaps',
  --     --   'name',
  --     --   'remaps',
  --     --   'recents',
  --     -- },

  --     -- For true speed, it has the type string[][],
  --     --  each element of the shortcuts array contains two strings, the first is the key, the second is a match string to a directory
  --     --   for example, I have ~/.config/nvim as shortcut f, so I can type `f` to go to my neovim dotfiles, this is set with { { "f", ".config/nvim" } }
  --     -- shortcuts = {
  --     --   { 'f', '.config/nvim' },
  --     -- },

  --     --- Set to true to have more verbose logging
  --     debug = true,

  --     -- The path to the log file
  --     logPath = vim.fn.stdpath 'log' .. '/spaceport.log',

  --     -- How many hours to preserve each log entry for
  --     -- logPreserveHours = 24,
  --   },
  -- },
}
