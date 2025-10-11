local opts = require("prompts._core.opts")
local outputbuf = require("prompts._core.outputbuf")
local store = require("prompts._core.history.store")

local M = {}

---@class prompts.history.Entry
---@field file string
---@field command string
---@field action? string
---@field prompt? string
---@field timestamp integer
---@field lines string[]

---@class prompts.history.Job
---@field file string
---@field command string
---@field action? string
---@field userprompt? string
---@field buffer integer

---@alias prompts.history.EntryList prompts.history.Entry[]

---Format the header line for a history entry.
---@param entry prompts.history.Entry
---@return string header
local function format_header(entry)
  local timestamp = os.date("%Y-%m-%d %H:%M:%S", entry.timestamp)
  local command = entry.command ~= "" and entry.command or "AI output"
  local header = string.format("## %s — %s", timestamp, command)
  if entry.action and entry.action ~= "" then
    header = string.format("%s (%s)", header, entry.action)
  end
  return header
end

---Build a list of renderable lines for the supplied history entries.
---@param entries prompts.history.EntryList
---@return string[] lines
local function build_lines(entries)
  ---@type string[]
  local lines = {}

  for _, entry in ipairs(entries) do
    ---@type string[]
    local entry_lines = {}
    table.insert(entry_lines, format_header(entry))

    if entry.prompt and entry.prompt ~= "" then
      table.insert(entry_lines, string.format("_Prompt_: %s", entry.prompt))
    end

    if entry.lines and #entry.lines > 0 then
      if entry.prompt and entry.prompt ~= "" then
        table.insert(entry_lines, "")
      end
      vim.list_extend(entry_lines, entry.lines)
    end

    if #entry_lines > 0 then
      if #lines > 0 and lines[#lines] ~= "" then
        table.insert(lines, "")
      end
      vim.list_extend(lines, entry_lines)
    end
  end

  while #lines > 0 and lines[#lines] == "" do
    table.remove(lines)
  end

  return lines
end

---Initialize the history subsystem by ensuring the base directory exists.
---@return nil
function M.setup()
  local config = opts.get()
  store.ensure_base_dir(config.history_dir)
end

---Persist job output to history and refresh the buffer when saved.
---@param job prompts.history.Job
---@return nil
function M.save(job)
  if not job or not job.buffer or not vim.api.nvim_buf_is_valid(job.buffer) then
    return
  end

  ---@type string[]
  local lines = vim.api.nvim_buf_get_lines(job.buffer, 0, -1, false)
  local config = opts.get()
  local saved = store.save({
    file = job.file,
    command = job.command,
    action = job.action,
    prompt = job.userprompt,
    timestamp = os.time(),
  }, lines, config)

  if not saved then
    return
  end

  if vim.api.nvim_buf_is_valid(job.buffer) then
    M.render(job.file, job.buffer)
  end
end

---Render the history for a file into the provided buffer.
---@param file string
---@param bufnr integer
---@return boolean rendered
function M.render(file, bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  local config = opts.get()
  ---@type prompts.history.EntryList
  local entries = store.load(file, config)
  ---@type string[]
  local lines = build_lines(entries)
  outputbuf.replace(bufnr, lines)
  return #lines > 0
end

return M
