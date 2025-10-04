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
The user selected the following code in Neovim:

```
%s
```

You must base your answer only on this code selection.
]]

local TEMPLATE_REQUEST_WITH_SELECTION = [[
The user's question about that selected code is:

%s
]]

local TEMPLATE_REQUEST = [[
The user's question is:

%s
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
  local parts = {}

  if selection ~= '' then
    table.insert(parts, selection)
  end

  if request ~= '' then
    local template = selection ~= '' and TEMPLATE_REQUEST_WITH_SELECTION or TEMPLATE_REQUEST
    table.insert(parts, string.format(template, request))
  end

  return table.concat(parts, "\n\n")
end

return M
