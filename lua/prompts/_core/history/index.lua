local M = {}

--- Read history entries from a JSON file.
---@param path string Absolute path to the history file.
---@return table entries Decoded history data, defaults to an empty entry list on failure.
local function read(path)
  local ok, content = pcall(vim.fn.readfile, path)
  if not ok then
    return { entries = {} }
  end

  local raw = table.concat(content, "\n")
  if raw == "" then
    return { entries = {} }
  end

  local ok_decode, data = pcall(vim.fn.json_decode, raw)
  if not ok_decode or type(data) ~= "table" then
    return { entries = {} }
  end

  if type(data.entries) ~= "table" then
    data.entries = {}
  end

  return data
end

--- Persist history entries to a JSON file.
---@param path string Absolute path to the history file.
---@param data table History data containing an entries array.
local function write(path, data)
  local encoded = vim.fn.json_encode(data)
  vim.fn.writefile({ encoded }, path)
end

--- Remove oldest entries when exceeding a count limit.
---@param entries table<number, table> Ordered list of history entries.
---@param limit number Maximum number of entries to keep.
---@return table<number, table> removed Entries removed to satisfy the limit.
local function prune_by_count(entries, limit)
  if not limit or limit <= 0 then
    return {}
  end

  local removed = {}
  while #entries > limit do
    table.insert(removed, table.remove(entries, 1))
  end
  return removed
end

--- Remove oldest entries when exceeding a cumulative size limit.
---@param entries table<number, table> Ordered list of history entries.
---@param limit number Maximum total size (bytes) to keep.
---@return table<number, table> removed Entries removed to satisfy the limit.
local function prune_by_size(entries, limit)
  if not limit or limit <= 0 then
    return {}
  end

  local removed = {}
  local total = 0
  for _, entry in ipairs(entries) do
    total = total + (entry.size or 0)
  end

  while total > limit and #entries > 0 do
    local removed_entry = table.remove(entries, 1)
    total = total - (removed_entry.size or 0)
    table.insert(removed, removed_entry)
  end

  return removed
end

--- Append a new history entry and prune according to configuration limits.
---@param path string Absolute path to the history file.
---@param entry table The entry to store, containing timestamp, id, and size.
---@param config table History configuration with history_max_entries and history_max_bytes.
---@return table<number, table> removed Entries removed during pruning.
function M.update(path, entry, config)
  local data = read(path)
  local entries = data.entries

  table.insert(entries, entry)
  table.sort(entries, function(a, b)
    if a.timestamp == b.timestamp then
      return a.id < b.id
    end
    return a.timestamp < b.timestamp
  end)

  local removed = {}
  for _, item in ipairs(prune_by_count(entries, config.history_max_entries)) do
    table.insert(removed, item)
  end
  for _, item in ipairs(prune_by_size(entries, config.history_max_bytes)) do
    table.insert(removed, item)
  end

  data.entries = entries
  write(path, data)

  return removed
end

--- List all stored history entries from disk.
---@param path string Absolute path to the history file.
---@return table<number, table> entries Ordered list of history entries.
function M.list(path)
  return read(path).entries
end

--- Remove specific history entries from disk.
---@param path string Absolute path to the history file.
---@param ids table<string, boolean> Set of entry ids to remove.
function M.remove(path, ids)
  if not ids or vim.tbl_isempty(ids) then
    return
  end

  local data = read(path)
  if #data.entries == 0 then
    return
  end

  local filtered = {}
  local changed = false
  for _, entry in ipairs(data.entries) do
    if ids[entry.id] then
      changed = true
    else
      table.insert(filtered, entry)
    end
  end

  if not changed then
    return
  end

  data.entries = filtered
  write(path, data)
end

return M
