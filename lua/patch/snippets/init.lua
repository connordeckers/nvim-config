local ls = require 'luasnip'

ls.add_snippets("typescript", require 'patch.snippets.typescript', { key = "typescript" })
ls.add_snippets("javascript", require 'patch.snippets.typescript', { key = "javascript" })
