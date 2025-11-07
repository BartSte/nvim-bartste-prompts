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

local TEMPLATE_INPUT = [[
The user provided the following text:

%s
]]

local TEMPLATE_SELECTION = [[
The user selected the following:

```
%s
```

You must base your answer only on this piece of text.
]]

function M.get_selection(args)
    if args.range == 0 then
        return nil
    end
    local lines = vim.api.nvim_buf_get_text(0, args.line1 - 1, 0, args.line2, 0, {})
    return string.format(TEMPLATE_SELECTION, table.concat(lines, "\n"))
end

function M.get_input(args)
    if args.args == '' then
        return nil
    end
    return string.format(TEMPLATE_INPUT, args.args)
end

---Create a user prompt template for code editing
---@param args UserCommandArgs The arguments for the user command
---@return string Formatted prompt template or empty string
function M.make(args)
    local parts = {}
    local selection = M.get_selection(args)
    local input = M.get_input(args)
    for _, value in ipairs({selection, input}) do
        if value then table.insert(parts, value) end
    end
    return table.concat(parts, "\n\n")
end

return M
