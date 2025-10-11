---@class PromptsFormatter
local M = {}

---@type string[]
local HEADER_PREFIXES = {
  "^Aider v",
  "^Main model:",
  "^Editor model:",
  "^Weak model:",
  "^Git repo:",
  "^Repo%-map:",
  "^Added ",
  "^Cost estimates",
}

--- Remove trailing whitespace from the provided text.
---@param text string
---@return string
local function trim_right(text)
  return text:gsub("%s+$", "")
end

--- Determine whether a line should be skipped entirely.
---@param line string
---@return boolean
local function should_skip_line(line)
  if line == "" then
    return false
  end
  if line:find("Warning: Input is not a terminal", 1, true) then
    return true
  end
  if line:find("Γ", 1, true) then
    return true
  end
  return false
end

--- Check if a line is part of the formatted header section.
---@param line string
---@return boolean
local function is_header_line(line)
  for _, pattern in ipairs(HEADER_PREFIXES) do
    if line:match(pattern) then
      return true
    end
  end
  return false
end

--- Collapse consecutive blank lines while preserving single separators.
---@param lines string[]
---@return string[]
local function squash_blank_lines(lines)
  local result = {}
  local previous_blank = false
  for _, line in ipairs(lines) do
    if line == "" then
      if not previous_blank and #result > 0 then
        table.insert(result, "")
      end
      previous_blank = true
    else
      table.insert(result, line)
      previous_blank = false
    end
  end
  while result[#result] == "" do
    table.remove(result)
  end
  return result
end

--- Append a block of lines to the target, optionally compressing blanks.
---@param target string[]
---@param block string[]
---@param compress_blank boolean
local function append_block(target, block, compress_blank)
  if compress_blank then
    block = squash_blank_lines(block)
  end
  if #block == 0 then
    return
  end
  if #target > 0 and target[#target] ~= "" then
    table.insert(target, "")
  end
  vim.list_extend(target, block)
end

--- Format the contents of the specified buffer according to output rules.
---@param bufnr integer|nil
---@return nil
function M.format_buffer(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  ---@type string[]
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if #lines == 0 then
    return
  end

  ---@type string[]
  local cleaned = {}
  for _, line in ipairs(lines) do
    local trimmed = trim_right(line)
    if trimmed == "" then
      table.insert(cleaned, "")
    elseif not should_skip_line(trimmed) then
      table.insert(cleaned, trimmed)
    end
  end

  while cleaned[1] == "" do
    table.remove(cleaned, 1)
  end
  while cleaned[#cleaned] == "" do
    table.remove(cleaned)
  end
  if #cleaned == 0 then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
    return
  end

  ---@type string[]
  local header = {}
  local index = 1
  while index <= #cleaned and is_header_line(cleaned[index]) do
    table.insert(header, cleaned[index])
    index = index + 1
    if cleaned[index] == "" then
      index = index + 1
    end
  end

  while index <= #cleaned and cleaned[index] == "" do
    index = index + 1
  end

  ---@type integer|nil
  local tokens_index
  for i = index, #cleaned do
    if cleaned[i]:find("^Tokens:") then
      tokens_index = i
      break
    end
  end

  ---@type string[]
  local body = {}
  ---@type string[]
  local footer = {}

  local body_end = tokens_index and tokens_index - 1 or #cleaned
  for i = index, body_end do
    table.insert(body, cleaned[i])
  end
  if tokens_index then
    for i = tokens_index, #cleaned do
      table.insert(footer, cleaned[i])
    end
  end

  ---@type string[]
  local formatted = {}
  append_block(formatted, header, false)
  append_block(formatted, body, true)
  append_block(formatted, footer, true)

  while formatted[#formatted] == "" do
    table.remove(formatted)
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted)
end

return M
