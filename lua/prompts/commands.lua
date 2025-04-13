local M = {}

local lock = ''

--- Creates a command function that runs a given command on the current buffer file.
---@param command string The command to run.
---@return function A function without parameters that executes the command.
function M.make(command)
  return function()
    M.run(command)
  end
end

--- Handle command completion results and notify user
---@param obj table Command exit information containing:
---@field code number Exit status code (0 for success)
---@field stdout string Captured standard output
---@field stderr string Captured standard error
local function on_exit(obj)
  if obj.code ~= 0 then
    vim.notify(string.format("Command failed with exit code: %d", obj.code), vim.log.levels.ERROR)
    vim.notify(string.format("stderr: %s", obj.stderr), vim.log.levels.ERROR)
    vim.notify(string.format("stdout: %s", obj.stdout), vim.log.levels.INFO)
  else
    vim.notify("Command succeeded", vim.log.levels.INFO)
  end
  lock = ''
end

--- Execute a system command for the current buffer with concurrency control
---@param command string The identifier of the command to execute
---@private
local function run(command)
  if lock ~= '' then
    vim.notify(string.format("Another command '%s' is already running", lock), vim.log.levels.WARN)
    return
  end

  lock = command
  local file = vim.api.nvim_buf_get_name(0)
  local filetype = vim.bo.filetype
  local cmd = { "prompts", command, file, "--filetype", filetype, "--action", "aider" }
  vim.notify(string.format("Running: %s", table.concat(cmd, " ")))
  vim.system(cmd, {}, on_exit)
end

--- Safely execute a command with error protection
--- @param command string The identifier of the command to run
function M.run(command)
  local ok, _ = pcall(run, command)
  if not ok then
    vim.notify(string.format("Command %s failed", command), vim.log.levels.ERROR)
    lock = ''
  end
end

return M
