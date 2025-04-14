local M = {}

local lock = ''

--- Handles command execution cleanup and notification
---@param file string Path to the file being processed
---@return function # Wrapped callback function for vim.schedule_wrap
local function schedule_on_exit(file)
  return vim.schedule_wrap(function(obj)
    if obj.code ~= 0 then
      vim.notify(string.format("Command failed with exit code: %d", obj.code), vim.log.levels.ERROR)
      vim.notify(string.format("stderr: %s", obj.stderr), vim.log.levels.ERROR)
      vim.notify(string.format("stdout: %s", obj.stdout), vim.log.levels.INFO)
    else
      vim.notify("Command succeeded", vim.log.levels.INFO)
      vim.cmd("e " .. file)
    end
    lock = ''
  end)
end

--- Executes a system command with concurrency control
---@param command string Command identifier to execute
---@private
---@note Uses global lock mechanism to prevent concurrent executions
---@sideeffect Modifies global lock state and creates system process
---@emits vim.notify for command status updates
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
  vim.system(cmd, {}, schedule_on_exit(file))
end

--- Safely executes a command using pcall error protection
---@param command string Command identifier to execute
---@see run # The internal implementation function
---@sideeffect May modify global lock state
---@return boolean # pcall success status
---@return any # pcall return value or error message
function M.run(command)
  local ok, _ = pcall(run, command)
  if not ok then
    vim.notify(string.format("Command %s failed", command), vim.log.levels.ERROR)
    lock = ''
  end
end

--- Creates a command closure for execution
---@param command string Command identifier to bind
---@return function # Parameterless function that triggers command execution
---@usage local cmd = M.make("format") -- Creates cmd() function that runs formatter
function M.make(command)
  return function()
    M.run(command)
  end
end

return M
