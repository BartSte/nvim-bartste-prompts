local M = {}

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

local function trim_right(text)
  return text:gsub("%s+$", "")
end

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

local function is_header_line(line)
  for _, pattern in ipairs(HEADER_PREFIXES) do
    if line:match(pattern) then
      return true
    end
  end
  return false
end

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

  local tokens_index
  for i = index, #cleaned do
    if cleaned[i]:find("^Tokens:") then
      tokens_index = i
      break
    end
  end

  local body = {}
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
