-- NOTE copied from core
local M = {}

local to_severity = function(severity)
  if type(severity) == 'string' then
    return assert(
      vim.diagnostic.severity[string.upper(severity)],
      string.format('Invalid severity: %s', severity)
    )
  end
  return severity
end

local filter_by_severity = function(severity, diagnostics)
  if not severity then
    return diagnostics
  end

  if type(severity) ~= 'table' then
    severity = to_severity(severity)
    return vim.tbl_filter(function(t)
      return t.severity == severity
    end, diagnostics)
  end

  local min_severity = to_severity(severity.min) or vim.diagnostic.severity.HINT
  local max_severity = to_severity(severity.max) or vim.diagnostic.severity.ERROR

  return vim.tbl_filter(function(t)
    return t.severity <= min_severity and t.severity >= max_severity
  end, diagnostics)
end

M.filter = function(bufnr, diagnostics, opts)
  return filter_by_severity(opts.severity, diagnostics)
end

local function count_sources(bufnr)
  local seen = {}
  local count = 0
  -- TODO core caches this, should we also?
  for _, diagnostic in ipairs(vim.diagnostic.get(bufnr)) do
    if diagnostic.source and not seen[diagnostic.source] then
      seen[diagnostic.source] = true
      count = count + 1
    end
  end
  return count
end

local function prefix_source(diagnostics)
  return vim.tbl_map(function(d)
    if not d.source then
      return d
    end

    local t = vim.deepcopy(d)
    t.message = string.format('%s: %s', d.source, d.message)
    return t
  end, diagnostics)
end

local function reformat_diagnostics(format, diagnostics)
  vim.validate({
    format = { format, 'f' },
    diagnostics = { diagnostics, 't' },
  })

  local formatted = vim.deepcopy(diagnostics)
  for _, diagnostic in ipairs(formatted) do
    diagnostic.message = format(diagnostic)
  end
  return formatted
end

M.format = function(bufnr, diagnostics, opts)
  if opts.format then
    diagnostics = reformat_diagnostics(opts.format, diagnostics)
  end
  if
    opts.source
    and (opts.source ~= 'if_many' or count_sources(bufnr) > 1)
  then
    diagnostics = prefix_source(diagnostics)
  end
  return diagnostics
end

return M
