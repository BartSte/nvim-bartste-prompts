---@class prompts.Job
---Represents an individual prompt execution job and its associated resources
---@field command string Shell command to execute with placeholder substitution
---@field file string Absolute path to source file being processed
---@field filetype string Filetype for syntax highlighting/processing
---@field tmp string Temporary file path used for processing operations
---@field action string the <value> for `prompt <command> --action <value>`.
---@field process table|nil Job process handle from vim.fn.jobstart
---@field userprompt string User-provided input captured from prompt dialog
---@field buffer integer Neovim buffer ID for output streaming
---@field cwd string? Working directory when the job was created

local userprompt = require("prompts._core.userprompt")
local opts = require("prompts._core.opts")
local log = require("prompts._core.log")

local M = {}

---Create a new job instance for prompt execution
---@param command string Shell command template with placeholders
---@param file string Absolute path to source file being processed
---@param filetype string Filetype for syntax-aware processing
---@param action string the <value> for `prompt <command> --action <value>`.
---@param args table Arguments containing line range (line1, line2, range)
---@return prompts.Job job Initialized job instance
function M.new(command, file, filetype, action, args)
  local basename = vim.fn.fnamemodify(file, ":t")
  local hash = vim.fn.sha256(vim.fn.fnamemodify(file, ":p")):sub(1, 8)
  local job = {
    command = command,
    file = file,
    filetype = filetype,
    action = action,
    process = nil,
    tmp = string.format("%s/%s-%s", opts.get().backup_dir, hash, basename),
    userprompt = userprompt.make(args),
    buffer = nil,
    cwd = vim.loop.cwd(),
  }
  log.debug("Created job: %s", vim.inspect(job))
  return job
end

return M
