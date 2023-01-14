local M = {}

M.item_types = {
	["*.component.ts"] = { label = "Component", ordinal = 1000, selector = "selector" },
	["*.module.ts"] = { label = "Module", ordinal = 2000, selector = nil },
	["*.directive.ts"] = { label = "Directive", ordinal = 3000, selector = "selector" },
	["*.pipe.ts"] = { label = "Pipe", ordinal = 4000, selector = "name" }
}

return M
