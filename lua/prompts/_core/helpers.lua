--- Helper functions for various tasks.
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

--- Append lines to a buffer.
---@param bufnr? integer Buffer number, or nil to skip.
---@param lines string|table Lines to append (string or table of strings)
function M.append_to_buffer(bufnr, lines)
  if not bufnr then
    return
  end
  if type(lines) == "string" then
    lines = vim.split(lines, "\n", { trimempty = true })
  end

  -- Skip empty lines
  if not lines or #lines == 0 then
    return
  end

  -- Schedule buffer updates in main event loop
  vim.schedule(function()
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    vim.api.nvim_buf_set_lines(bufnr, line_count, line_count, false, lines)
  end)
end

return M
