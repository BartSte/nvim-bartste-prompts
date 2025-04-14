local M = {}

local lock = ''

local function schedule_on_exit(file)
  return vim.schedule_wrap(function(obj)
    if obj.code ~= 0 then
      vim.notify(string.format("Command failed with exit code: %d", obj.code), vim.log.levels.ERROR)
      vim.notify(string.format("stderr: %s", obj.stderr), vim.log.levels.ERROR)
      vim.notify(string.format("stdout: %s", obj.stdout), vim.log.levels.INFO)
    else
      vim.notify("Command succeeded", vim.log.levels.INFO)
      vim.cmd("edit " .. file)
    end
    lock = ''
  end)
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
  vim.system(cmd, {}, schedule_on_exit(file))
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

--- Creates a command function that runs a given command on the current buffer file.
---@param command string The command to run.
---@return function A function without parameters that executes the command.
function M.make(command)
  return function()
    M.run(command)
  end
end

return M
