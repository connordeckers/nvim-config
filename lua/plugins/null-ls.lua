local null_ls = {
  sources = {
    code_actions = {
      -- 'eslint_d',
      'gitrebase',
      'ts_node_action',
    },
    diagnostics = {
      -- 'actionlint',
      -- 'alex',
      -- 'cmake_lint',
      'commitlint',
      -- 'eslint_d',
      -- 'cpplint',
      -- 'dotenv_linter',
      -- 'fish',
      -- 'gitlint',
      -- 'hadolint',
      -- 'jsonlint',
      -- 'markdownlint',
      -- 'stylelint',
      -- 'todo_comments',
    },
    completion = { 'tags' },
    formatting = {
      'fish_indent',
      -- 'fixjson',
      'nginx_beautifier',
      'rustfmt',
      'stylelint',
      'stylua',
      'xmlformat',
      'yamlfmt',
      {
        'prettierd',
        {
          filetypes = {
            'css',
            'graphql',
            'html',
            'javascript',
            'javascriptreact',
            'json',
            'less',
            'markdown',
            'scss',
            'typescript',
            'typescriptreact',
            'yaml',
          },
          timeout = 5000,
        },
      },
    },
  },
}

function null_ls.configure()
  local null = require 'null-ls'
  local sources = {
    -- require 'utils.null-ls-postprocess.todo_comments'
  }

  for cat, srcs in pairs(null_ls.sources) do
    for _, src in ipairs(srcs) do
      if type(src) == 'string' then
        table.insert(sources, null.builtins[cat][src])
      elseif type(src) == 'table' then
        table.insert(sources, null.builtins[cat][src[1]].with(src[2]))
      end
    end
  end

  -- for _, src in ipairs(null_ls.custom_sources) do
  -- local path = 'plugins.null-ls-postprocess.' .. src
  --   local modok, _ = pcall(require, path)
  --   if not modok then
  --     vim.notify('Error fetching ' .. src .. ' from ' .. '"' .. path .. '"', vim.log.levels.ERROR)
  --   end
  -- end

  return sources
end

return {
  {
    'jayp0521/mason-null-ls.nvim',
    opts = { automatic_installation = true, automatic_setup = true },
    lazy = true,
  },
  {
    'ckolkey/ts-node-action',
    dependencies = { 'nvim-treesitter' },
    opts = {},
  },
  {
    'nvimtools/none-ls.nvim',
    event = 'VeryLazy',
    dependencies = { 'mason.nvim', 'mason-null-ls.nvim' },
    opts = function()
      return {
        root_dir = require('null-ls.utils').root_pattern('.null-ls-root', '.neoconf.json', 'Makefile', '.git'),
        sources = null_ls.configure(),
      }
    end,
  },
}

-- return {}
