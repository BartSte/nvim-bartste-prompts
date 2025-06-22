---@class UserCommandArgs
---@field name string
---@field args string     # raw args string
---@field fargs string[]  # split args
---@field bang boolean
---@field line1 integer
---@field line2 integer
---@field range integer
---@field count integer
---@field smods table

local M = {}

local TEMPLATE_SELECTION = [[

You MUST only consider the following piece of code:

```
%s
```

Any other code MUST be ignored.
]]

function M.make_selection(args)
  if args.range == 0 then
    return ''
  end
  local lines = vim.api.nvim_buf_get_text(0, args.line1 - 1, 0, args.line2, 0, {})
  return string.format(TEMPLATE_SELECTION, table.concat(lines, "\n"))
end

---Extract the request string from the command arguments.
---@param args UserCommandArgs The arguments passed to the user command
---@return string The raw request string, or an empty string if none
function M.make_request(args)
  return args.args or ''
end

---Create a user prompt template for code editing
---@param args UserCommandArgs The arguments for the user command
---@return string Formatted prompt template or empty string
function M.make(args)
  local selection = M.make_selection(args)
  local request = M.make_request(args)
  return string.format("%s%s", selection, request)
end

return M
