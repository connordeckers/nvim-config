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

local function kebabCase(args, parent, user_args)
  local matching = args[1][1]
  local firstLetter = string.sub(matching, 1, 1)
  local restOfWord = string.gsub(string.sub(matching, 2), '%u', function(c)
    return '-' .. c
  end)

  return string.lower(firstLetter .. restOfWord)
end

local collection = {
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

  snippet(
    'component',
    fmt(
      [[
@customElement("mylo-mate-{dashed}")
export class {name} extends LitElement {{
	/**************************************
	 * Properties
	 **************************************/

	/**************************************
	 * Methods: lifecycle
	 **************************************/

	constructor() {{ 
	  super(); 
	}}

	/**************************************
	 * Methods: render
	 **************************************/

	render() {{
		return html`<p>Component "{name}" works!</p>`;
	}}

	/**************************************
	 * Methods: other
	 **************************************/

}}
		]],
      {
        name = insert(1, 'ClassName'),
        dashed = func(kebabCase, { 1 }),
      },
      { repeat_duplicates = true }
    )
  ),

  snippet(
    'module',
    fmt(
      [[
import {{ Augmentation, Module }} from "@helpers";

@Augmentation({{ 
	target: [""], 
	testURLs: [],  
	config: {{
		category: "",
		key: "",
		label: "",
		type: "boolean",
		default: true,
		description: null
	}}
}})
export class {name} extends Module {{

	/**************************************
	* Properties
	**************************************/

	/**************************************
	* Methods: testing
	**************************************/

	test__pre(): boolean {{
		return true;
	}}

	test__post(): boolean {{
		return false;
	}}

	shouldRun(): boolean {{
		return true;
	}}

	/**************************************
	* Methods: lifecycle
	**************************************/

	/** Run when the feature is enabled. See {{@link shouldRun}}. */
	async enabled() {{
		console.log(`Running module "{name}"`)
	}}

	/** Run when the feature is disabled, after having been enabled in this page load. */
	disabled() {{}}

	async prepare() {{

	}}

	/**************************************
	* Methods: other
	**************************************/


}}
		]],
      { name = insert(1, 'ClassName') }
    )
  ),
}

return collection
