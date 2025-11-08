local log = require("prompts._core.log")

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

local TEMPLATE = [[
The user provided the following text:

%s
]]

function M.get_selection(args)
  if args.range == 0 then
    return nil
  end
  local lines = vim.api.nvim_buf_get_text(0, args.line1 - 1, 0, args.line2, 0, {})
  return string.format(TEMPLATE, table.concat(lines, "\n"))
end

function M.get_input(args)
  if args.args == '' then
    return nil
  end
  return string.format(TEMPLATE, args.args)
end

---Create a user prompt template for code editing
---@param args UserCommandArgs The arguments for the user command
---@return string Formatted prompt template or empty string
function M.make(args)
  log.debug("Creating user prompt with args: %s", vim.inspect(args))
  local parts = {}

  local selection = M.get_selection(args)
  if selection then
    table.insert(parts, selection)
  end

  local input = M.get_input(args)
  if input then
    table.insert(parts, input)
  end

  local prompt = table.concat(parts, "\n\n")
  log.debug("User prompt is: %s", prompt)
  return prompt
end

return M
