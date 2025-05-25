local M = {}

function M.diff(file1, file2)
  local a = table.concat(vim.fn.readfile(file1))
  local b = table.concat(vim.fn.readfile(file2))
  return a ~= b
end

return M
