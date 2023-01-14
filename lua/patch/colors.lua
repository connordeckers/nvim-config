local theme = require 'onedark'
theme.setup {
  style = 'dark',
  transparent = false,
  code_style = {
    comments = 'italic',
    keywords = 'italic',
    functions = 'none',
    strings = 'none',
    variables = 'none',
  },
}
theme.load()
