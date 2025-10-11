local index = require("prompts._core.history.index")
local uv = vim.loop

local M = {}

--- Resolve the base directory for storing history entries.
---@param config table|nil Configuration table with optional history_dir.
---@return string base_dir Absolute path to the history base directory.
local function resolve_base_dir(config)
  local dir = config.history_dir
  if not dir or dir == "" then
    dir = vim.fn.stdpath("data") .. "/prompts/history"
  end
  return dir
end

--- Sanitize a file name so it can be used as a directory component.
---@param name string Original file name.
---@return string sanitized Sanitized name with unsafe characters replaced.
local function sanitize(name)
  name = name:gsub("[^%w%-%._]", "_")
  if name == "" then
    return "output"
  end
  return name
end

--- Resolve file system paths required to store history for a file.
---@param meta table Metadata containing the file path.
---@param config table|nil History configuration.
---@return table paths Table containing base_dir, file_dir, and index_path.
local function resolve_paths(meta, config)
  local base = resolve_base_dir(config)
  local file_abs = vim.fn.fnamemodify(meta.file, ":p")
  local hash = vim.fn.sha256(file_abs):sub(1, 12)
  local name = sanitize(vim.fn.fnamemodify(file_abs, ":t"))
  local dir = string.format("%s/%s-%s", base, name, hash)
  return {
    base_dir = base,
    file_dir = dir,
    index_path = dir .. "/index.json",
  }
end

--- Ensure the base directory for history exists.
---@param dir string|nil Directory path to ensure.
function M.ensure_base_dir(dir)
  dir = dir and dir ~= "" and dir or (vim.fn.stdpath("data") .. "/prompts/history")
  vim.fn.mkdir(dir, "p")
end

--- Normalize a list of lines by coercing types and trimming blank edges.
---@param lines table|nil List of lines to normalize.
---@return string[] normalized Normalized list of lines.
local function normalize_lines(lines)
  if type(lines) ~= "table" then
    return {}
  end

  local normalized = {}
  for _, line in ipairs(lines) do
    table.insert(normalized, type(line) == "string" and line or tostring(line))
  end

  while #normalized > 0 and normalized[#normalized] == "" do
    table.remove(normalized)
  end
  while #normalized > 0 and normalized[1] == "" do
    table.remove(normalized, 1)
  end

  return normalized
end

--- Save a history entry for the given metadata and lines.
---@param meta table Metadata including file, timestamp, command, action, and prompt.
---@param lines table|nil Lines to persist.
---@param config table|nil History configuration.
---@return boolean saved True if content was written, false otherwise.
function M.save(meta, lines, config)
  local cleaned = normalize_lines(lines)
  if #cleaned == 0 then
    return false
  end

  local paths = resolve_paths(meta, config)
  M.ensure_base_dir(paths.base_dir)
  vim.fn.mkdir(paths.file_dir, "p")

  local id = tostring(uv.hrtime())
  local entry_path = string.format("%s/%s.txt", paths.file_dir, id)
  vim.fn.writefile(cleaned, entry_path)

  local stat = uv.fs_stat(entry_path)
  local size = stat and stat.size or 0

  local removed = index.update(paths.index_path, {
    id = id,
    path = entry_path,
    timestamp = meta.timestamp or os.time(),
    command = meta.command or "",
    action = meta.action or "",
    prompt = meta.prompt or "",
    size = size,
  }, config)

  for _, entry in ipairs(removed) do
    if entry.path and entry.path ~= entry_path then
      vim.fn.delete(entry.path)
    end
  end

  return true
end

--- Load history entries for a file.
---@param file string Absolute or relative file path.
---@param config table|nil History configuration.
---@return table entries Ordered list of history entries.
function M.load(file, config)
  local paths = resolve_paths({ file = file }, config)
  local entries = index.list(paths.index_path)
  if not entries or #entries == 0 then
    return {}
  end

  local missing = {}
  local result = {}

  for _, entry in ipairs(entries) do
    local stat = uv.fs_stat(entry.path)
    if not stat then
      missing[entry.id] = true
    else
      local content = vim.fn.readfile(entry.path)
      table.insert(result, {
        id = entry.id,
        timestamp = entry.timestamp,
        command = entry.command,
        action = entry.action,
        prompt = entry.prompt,
        lines = content,
      })
    end
  end

  if next(missing) then
    index.remove(paths.index_path, missing)
  end

  table.sort(result, function(a, b)
    if a.timestamp == b.timestamp then
      return a.id < b.id
    end
    return a.timestamp < b.timestamp
  end)

  return result
end

return M
