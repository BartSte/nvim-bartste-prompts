local M = {}

local TEMPLATE = [[
You MUST only consider the following piece of code:

```
%s
```

Any other code MUST be ignored.
]]

---Create a user prompt template for code editing
---@param startline integer Starting line number (1-based)
---@param stopline integer Ending line number (1-based)
---@param range integer Number of lines selected (0 if no range)
---@return string Formatted prompt template or empty string
function M.new(startline, stopline, range)
  if range == 0 then
    return ''
  end
  local lines = vim.api.nvim_buf_get_text(0, startline - 1, 0, stopline, 0, {})
  return string.format(TEMPLATE, table.concat(lines, "\n"))
end

return M
