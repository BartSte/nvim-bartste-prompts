--- Helper functions to compare file contents.
---@module prompts._core.helpers
local M = {}

--- Determine if two files differ by comparing their contents.
---@param file1 string Path to the first file
---@param file2 string Path to the second file
---@return boolean True if files differ, false otherwise
function M.diff(file1, file2)
  local a = table.concat(vim.fn.readfile(file1))
  local b = table.concat(vim.fn.readfile(file2))
  return a ~= b
end

return M
