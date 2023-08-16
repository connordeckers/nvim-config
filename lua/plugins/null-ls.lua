local null_ls = {}
null_ls.sources = {
  code_actions = { 'eslint_d', 'gitrebase', 'ts_node_action' },
  diagnostics = {
    'actionlint',
    'alex',
    'cmake_lint',
    'commitlint',
    'cpplint',
    'dotenv_linter',
    'fish',
    'gitlint',
    'hadolint',
    'jsonlint',
    'markdownlint',
    'stylelint',
    'todo_comments',
  },
  completion = { 'tags' },
  formatting = {
    'fish_indent',
    'fixjson',
    'nginx_beautifier',
    'rustfmt',
    'stylelint',
    'stylua',
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
}

function null_ls.configure()
  local null_base = require 'null-ls'
  local sources = {}

  for cat, srcs in pairs(null_ls.sources) do
    for _, src in ipairs(srcs) do
      if type(src) == 'string' then
        table.insert(sources, null_base.builtins[cat][src])
      elseif type(src) == 'table' then
        table.insert(sources, null_base.builtins[cat][src[1]].with(src[2]))
      end
    end
  end

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
    'jose-elias-alvarez/null-ls.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'mason.nvim', 'mason-null-ls.nvim' },
    opts = function()
      -- The null-ls sources to use
      return {
        root_dir = require('null-ls.utils').root_pattern('.null-ls-root', '.neoconf.json', 'Makefile', '.git'),
        sources = null_ls.configure(),
      }
    end,
  },
}
