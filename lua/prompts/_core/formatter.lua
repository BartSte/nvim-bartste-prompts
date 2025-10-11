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
local ENTRY_START_PATTERN = HEADER_PREFIXES[1]

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
  return false
end

--- Check if a line is part of the formatted header section.
---@param line string
---@return boolean
local function is_header_line(line)
  if line:match("^Γ") then
    return true
  end
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
---@return nil
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

--- Remove leading and trailing blank lines from an entry.
---@param lines string[]
---@return string[]
local function trim_entry_edges(lines)
  local first = 1
  while first <= #lines and lines[first] == "" do
    first = first + 1
  end

  local last = #lines
  while last >= first and lines[last] == "" do
    last = last - 1
  end

  if first > last then
    return {}
  end

  local result = {}
  for index = first, last do
    table.insert(result, lines[index])
  end
  return result
end

--- Split the raw lines into individual formatted entries.
---@param lines string[]
---@return string[][]
local function split_entries(lines)
  local entries = {}
  local current = {}
  local has_header = false

  local function push_current()
    if has_header and #current > 0 then
      table.insert(entries, trim_entry_edges(current))
    end
  end

  for _, line in ipairs(lines) do
    if line:match(ENTRY_START_PATTERN) then
      if has_header then
        push_current()
        current = {}
      end
      has_header = true
    end
    table.insert(current, line)
  end

  push_current()
  return entries
end

--- Format a single entry by separating header, body, and footer.
---@param lines string[]
---@return string[]
local function format_entry(lines)
  local entry = trim_entry_edges(lines)
  if #entry == 0 then
    return {}
  end

  local header = {}
  local index = 1
  while index <= #entry and is_header_line(entry[index]) do
    table.insert(header, entry[index])
    index = index + 1
    if index <= #entry and entry[index] == "" then
      index = index + 1
    end
  end

  while index <= #entry and entry[index] == "" do
    index = index + 1
  end

  local tokens_index
  for i = index, #entry do
    if entry[i]:find("^Tokens:") then
      tokens_index = i
      break
    end
  end

  local body_end = tokens_index and tokens_index - 1 or #entry
  local body, footer = {}, {}

  for i = index, body_end do
    table.insert(body, entry[i])
  end
  if tokens_index then
    for i = tokens_index, #entry do
      table.insert(footer, entry[i])
    end
  end

  local formatted = {}
  append_block(formatted, header, false)
  append_block(formatted, body, true)
  append_block(formatted, footer, true)

  while #formatted > 0 and formatted[#formatted] == "" do
    table.remove(formatted)
  end

  return formatted
end

--- Format the contents of the specified buffer according to output rules.
---@param bufnr integer|nil
---@return nil
function M.format_buffer(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if #lines == 0 then
    return
  end

  local cleaned = {}
  for _, line in ipairs(lines) do
    local trimmed = trim_right(line)
    if trimmed == "" then
      table.insert(cleaned, "")
    elseif not should_skip_line(trimmed) then
      table.insert(cleaned, trimmed)
    end
  end

  while #cleaned > 0 and cleaned[1] == "" do
    table.remove(cleaned, 1)
  end
  while #cleaned > 0 and cleaned[#cleaned] == "" do
    table.remove(cleaned)
  end

  if #cleaned == 0 then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
    return
  end

  local entries = split_entries(cleaned)
  if #entries == 0 then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
    return
  end

  local formatted = {}
  for _, entry in ipairs(entries) do
    local formatted_entry = format_entry(entry)
    if #formatted_entry > 0 then
      if #formatted > 0 and formatted[#formatted] ~= "" then
        table.insert(formatted, "")
      end
      vim.list_extend(formatted, formatted_entry)
    end
  end

  while #formatted > 0 and formatted[#formatted] == "" do
    table.remove(formatted)
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted)
end

return M
