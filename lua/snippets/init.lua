local ls = require 'luasnip'

ls.add_snippets("typescript", require 'snippets.typescript', { key = "typescript" })
ls.add_snippets("javascript", require 'snippets.typescript', { key = "javascript" })
