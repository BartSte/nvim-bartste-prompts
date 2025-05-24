---@class prompts.Job
---@field command string
---@field file string
---@field filetype string
---@field filecopy string
---@field process table|nil
---@field userprompt string

---@class prompts.Jobs
---@field new fun(command: string, file: string, filetype: string, args: table): table|nil
---@field get fun(file: string): table|nil
---@field delete fun(file: string): nil
local M = {}

local userprompt = require("prompts._core.userprompt")

---@type table<string, prompts.Job>
local jobs = {}

--- Create a new job instance for managing prompt execution
---@param command string The command to execute
---@param file string Path to the source file
---@param filetype string Filetype for syntax handling
---@param args table Arguments with line/range info
---@return prompts.Job New job instance or nil if conflict exists
function M.new(command, file, filetype, args)
  local job = {
    command = command,
    file = file,
    filetype = filetype,
    filecopy = vim.fn.tempname(),
    process = nil,
    userprompt = userprompt.new(args.line1, args.line2, args.range),
  }
  if jobs[file] ~= nil then
    vim.notify("A job is already running for file " .. file, vim.log.levels.ERROR)
    return nil
  end
  jobs[file] = job
  return job
end

--- Get a job instance by file path
---@param file string File path to lookup
---@return table|nil Job instance if exists
function M.get(file)
  return jobs[file]
end

--- Delete a job entry by file path
---@param file string File path to remove
function M.delete(file)
  jobs[file] = nil
end

return M
