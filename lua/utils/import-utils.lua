local M = {}

-- function M.lazy_load(package, method)
--   return function(...)
--     local success, pkg = pcall(require, package)
--     if success then
--       pkg[method](...)
--     end
--   end
-- end

function M.with(package, callback)
  local exists, pkg = pcall(require, package)
  if not exists then
    return nil
  end

  return callback(pkg)
end

---@class LazyLoadParam
---@field [1] string Package name
---@field [2]? string|fun(pkg) What to run
---@field [3]? any Parameters to pass to function
---@field args? any Parameters to pass to function
---@field accept_incoming? boolean Return function that can accept incoming parameters; useful for functions that need to handle values from key event

---@param tbl LazyLoadParam
function M.lazy_load(tbl)
  return function()
    local props = {
      pkg = tbl[1],
      fn = tbl[2],
      args = tbl.args or tbl[3],
      accept_incoming = tbl.accept_incoming or false,
    }

    if not props.pkg then
      return nil
    end

    if not props.fn then
      return nil
    end

    local success, pkg = pcall(require, props.pkg)
    if success then
      local ret
      if type(props.fn) == 'function' then
        ret = props.fn(pkg)
      else
        ret = pkg[props.fn](props.args or {})
      end

      if props.accept_incoming then
        return function(...)
          return ret(...)
        end
      end
    end
  end
end

return M
