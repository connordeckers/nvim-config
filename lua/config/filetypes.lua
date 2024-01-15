vim.filetype.add {
  extension = {
    nu = 'nu',
  },
  pattern = {
    -- ['.*/etc/foo/.*'] = 'fooscript',
    -- Using an optional priority
    -- ['.*/etc/foo/.*%.conf'] = { 'dosini', { priority = 10 } },
    -- A pattern containing an environment variable
    ['${XDG_CONFIG_HOME}/sway/conf.d/.*'] = 'swayconfig',
    ['README.(%a+)$'] = function(path, bufnr, ext)
      if ext == 'md' then
        return 'markdown'
      elseif ext == 'rst' then
        return 'rst'
      end
    end,
  },
}

-- vim.filetype.add({
--    extension = {
--      foo = 'fooscript',
--      bar = function(path, bufnr)
--        if some_condition() then
--          return 'barscript', function(bufnr)
--            -- Set a buffer variable
--            vim.b[bufnr].barscript_version = 2
--          end
--        end
--        return 'bar'
--      end,
--    },
--    filename = {
--      ['.foorc'] = 'toml',
--      ['/etc/foo/config'] = 'toml',
--    },
--    pattern = {
--      ['.*/etc/foo/.*'] = 'fooscript',
--      -- Using an optional priority
--      ['.*/etc/foo/.*%.conf'] = { 'dosini', { priority = 10 } },
--      -- A pattern containing an environment variable
--      ['${XDG_CONFIG_HOME}/foo/git'] = 'git',
--      ['README.(%a+)$'] = function(path, bufnr, ext)
--        if ext == 'md' then
--          return 'markdown'
--        elseif ext == 'rst' then
--          return 'rst'
--        end
--      end,
--    },
--  })

--  vim.filetype.add {
--    pattern = {
--      ['.*'] = {
--        priority = -math.huge,
--        function(path, bufnr)
--          local content = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ''
--          if vim.regex([[^#!.*\\<mine\\>]]):match_str(content) ~= nil then
--            return 'mine'
--          elseif vim.regex([[\\<drawing\\>]]):match_str(content) ~= nil then
--            return 'drawing'
--          end
--        end,
--      },
--    },
--  }
