---@class prompts.Job
---Represents an individual prompt execution job and its associated resources
---@field command string Shell command to execute with placeholder substitution
---@field file string Absolute path to source file being processed
---@field filetype string Filetype for syntax highlighting/processing
---@field tmp string Temporary file path used for processing operations
---@field process table|nil Job process handle from vim.fn.jobstart
---@field userprompt string User-provided input captured from prompt dialog

---@class prompts.Jobs
---Manages collection of active prompt jobs with file-based indexing
---@field new fun(command: string, file: string, filetype: string, args: table): prompts.Job|nil Create and track new job
---@field get fun(file: string): prompts.Job|nil Get job by source file path
---@field delete fun(file: string): nil Remove job tracking and cleanup
local M = {}

local userprompt = require("prompts._core.userprompt")
local opts = require("prompts._core.opts")

---@type table<string, prompts.Job>
local jobs = {}

---Create and register a new job instance for prompt execution
---@param command string Shell command template with placeholders
---@param file string Absolute path to source file being processed
---@param filetype string Filetype for syntax-aware processing
---@param args table Arguments containing line range (line1, line2, range)
---@return prompts.Job? job Initialized job instance or nil if conflict exists
function M.new(command, file, filetype, args)
  if jobs[file] ~= nil then
    return nil
  end

  local basename = vim.fn.fnamemodify(file, ":t")
  local hash = vim.fn.sha256(vim.fn.fnamemodify(file, ":p")):sub(1,8)
  local job = {
    command = command,
    file = file,
    filetype = filetype,
    process = nil,
    tmp = string.format("%s/%s-%s", opts.get().backup_dir, hash, basename),
    userprompt = userprompt.new(args.line1, args.line2, args.range),
  }
  jobs[file] = job
  return job
end

---Retrieve job by source file path
---@param file string Absolute path used as job identifier
---@return prompts.Job? job Registered job instance or nil if not found
function M.get(file)
  return jobs[file]
end

---Remove job tracking entry and cleanup resources
---Safe to call on non-existent/non-running jobs (no-op)
---@param file string Absolute path used as job identifier
---@return nil
function M.delete(file)
  jobs[file] = nil
end

return M
