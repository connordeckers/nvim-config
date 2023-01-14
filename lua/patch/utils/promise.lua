local co = coroutine

local M = {}

function M.await(fn)
  local thread = co.running()
  local ret
  fn(function(...)
    if co.status(thread) == 'running' then
      ret = table.pack(...)
    else
      return co.resume(thread, ...)
    end
  end)

  if ret then
    return table.unpack(ret, 1, ret.n)
  else
    return co.yield()
  end
end

-- function M.all() end
--
-- function M.create(fn)
-- end

function M.create(fn)
  -- local thread = co.create(fn)
  -- local function async(...)
  --   local ok, data = co.resume(thread, ...)
  --
  --   if not ok then
  --     error(debug.traceback(thread, data))
  --   end
  --
  --   if co.status(thread) ~= 'dead' then
  --     data(async)
  --   end
  -- end
  -- async(...)

  return co.wrap(fn)
end

return M
