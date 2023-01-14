local ls = require 'luasnip'
-- some shorthands...
local snippet = ls.snippet
local snippet_node = ls.snippet_node
local text = ls.text_node
local insert = ls.insert_node
local func = ls.function_node
local choice = ls.choice_node
local dynamic = ls.dynamic_node
local restore = ls.restore_node
local lambda = require('luasnip.extras').lambda
local rep = require('luasnip.extras').rep
local partial = require('luasnip.extras').partial
local match = require('luasnip.extras').match
local nonempty = require('luasnip.extras').nonempty
local dynamic_lambda = require('luasnip.extras').dynamic_lambda
local fmt = require('luasnip.extras.fmt').fmt
local fmta = require('luasnip.extras.fmt').fmta
local types = require 'luasnip.util.types'
local conds = require 'luasnip.extras.expand_conditions'

-- args is a table, where 1 is the text in Placeholder 1, 2 the text in
-- placeholder 2,...
local function copy(args)
  return args[1]
end

local collection = {
  -- -- trigger is `fn`, second argument to snippet-constructor are the nodes to insert into the buffer on expansion.
  -- snippet("fn", {
  --   -- Simple static text.
  --   text("//Parameters: "),
  --   -- function, first parameter is the function, second the Placeholders
  --   -- whose text it gets as input.
  --   func(copy, 2),
  --   text({ "", "function " }),
  --   -- Placeholder/Insert.
  --   insert(1),
  --   text("("),
  --   -- Placeholder with initial text.
  --   insert(2, "int foo"),
  --   -- Linebreak
  --   text({ ") {", "\t" }),
  --   -- Last Placeholder, exit Point of the snippet.
  --   insert(0),
  --   text({ "", "}" }),
  -- }),

  snippet('af', {
    text { '(async () => {', '\t' },
    insert(1, ''),
    text { '', '})()' },
  }),

  snippet('qs', {
    text 'document.querySelector',
    choice(2, { text '', text 'All' }),
    text '("',
    insert(1, ''),
    text '")',
  }),

  snippet('doc', {
    text { '/**', '' },
    text ' * Package: ',
    insert(1, ''),
    text { '', ' * ', '' },
    text ' * ',
    insert(2, ''),
    text { '', ' */', '' },
    insert(0),
  }),
}

return collection
