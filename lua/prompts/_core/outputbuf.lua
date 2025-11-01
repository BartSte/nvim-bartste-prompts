---Utilities for managing prompt output buffers.
---@class prompts.outputbuf
local M = {}
local formatter = require("prompts._core.formatter")

local function normalize_lines(lines)
  if not lines then
    return {}
  end

  if type(lines) == "string" then
    lines = vim.split(lines, "\n", { trimempty = false })
  end

  if type(lines) ~= "table" then
    return {}
  end

  local normalized = {}
  for _, line in ipairs(lines) do
    if type(line) == "string" then
      if line:find("\n", 1, true) then
        local parts = vim.split(line, "\n", { trimempty = false })
        vim.list_extend(normalized, parts)
      else
        table.insert(normalized, line)
      end
    end
  end
  return normalized
end

---Create or reset the output buffer for a file.
---@param file string Path to the file generating output
---@return integer bufnr The buffer number for the output buffer
function M.new(file)
  ---@type integer
  local buf
  ---@type string
  local bufname = M.get_name(file)
  if vim.fn.bufexists(bufname) ~= 0 then
    buf = M.get(file)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
  else
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, bufname)
  end

  -- Set buffer options using vim.bo
  local bo = vim.bo[buf]
  bo.buftype = 'nofile'
  bo.modifiable = true
  bo.swapfile = false

  return buf
end

---Build the buffer name for the given file.
---@param file string Path to the file generating output
---@return string name The buffer name
function M.get_name(file)
  ---@type string
  local basename = vim.fn.fnamemodify(file, ":t")
  return string.format("prompts-output://%s", basename)
end

---Retrieve the buffer number for an output buffer.
---@param file string Path to the file generating output
---@return integer bufnr The buffer number, or -1 if not found
function M.get(file)
  local bufname = M.get_name(file)
  return vim.fn.bufnr(bufname)
end

---Append lines to the output buffer, formatting afterwards.
---@param bufnr integer Buffer number to append to
---@param lines string|string[] Lines to append
---@return nil
function M.append(bufnr, lines)
  if not bufnr then
    return
  end

  lines = normalize_lines(lines)
  if #lines == 0 then
    return
  end

  -- Schedule buffer updates in main event loop
  vim.schedule(function()
    ---@type integer
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    vim.api.nvim_buf_set_lines(bufnr, line_count, line_count, false, lines)
    formatter.format_buffer(bufnr)
  end)
end

function M.replace(bufnr, lines)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  lines = normalize_lines(lines)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  formatter.format_buffer(bufnr)
end

return M
