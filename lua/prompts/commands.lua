local M = {}

local lock = ''
local old = vim.fn.tempname()

--- Handles command execution cleanup and notification
---@param file string Path to the file being processed
---@return function Function to handle command completion
local function schedule_on_exit(file)
  vim.fn.writefile(vim.fn.readfile(file), old)
  return vim.schedule_wrap(function(obj)
    if obj.code ~= 0 then
      vim.notify(string.format("Command failed with exit code: %d", obj.code), vim.log.levels.ERROR)
      vim.notify(string.format("stderr: %s", obj.stderr), vim.log.levels.ERROR)
      vim.notify(string.format("stdout: %s", obj.stdout), vim.log.levels.INFO)
    else
      vim.notify("Command succeeded. Run :AiUndo to undo the changes.", vim.log.levels.INFO)
      vim.cmd(string.format("tabnew | e %s | diffsplit %s | set filetype=%s", file, old, vim.bo.filetype))
    end
    lock = ''
  end)
end

--- Executes a command with proper error handling and state management
---@param command string The command to execute
---@return boolean, any Returns pcall result (success status, error)
function M.run(command)
  -- Implements a global lock to prevent concurrent command executions
  -- Notifies command status through vim.notify
  -- Creates new buffer tab on success when fugitive is available
  if lock ~= '' then
    vim.notify(string.format("Another command '%s' is already running", lock), vim.log.levels.WARN)
    return false, "Command already running"
  end

  lock = command
  local file = vim.api.nvim_buf_get_name(0)
  local filetype = vim.bo.filetype
  local cmd = { "prompts", command, file, "--filetype", filetype, "--action", "aider" }
  vim.notify(string.format("Running command %s", command), vim.log.levels.INFO)
  vim.system(cmd, {}, schedule_on_exit(file))
  local ok, _ = pcall(run, command)
  if not ok then
    vim.notify(string.format("Command %s failed", command), vim.log.levels.ERROR)
    lock = ''
  end
end

--- Creates a command wrapper function for use in mappings/callbacks
---@param command string The command to execute when called
---@return function Function suitable for mappings/callbacks
function M.make(command)
  return function()
    M.run(command)
  end
end

--- Restores the previous version of the file
--- Validates existing backup file before attempting restoration
function M.undo()
  if old == '' or vim.fn.filereadable(old) == 0 then
    vim.notify("No previous version to restore", vim.log.levels.ERROR)
    return
  end

  local file = vim.api.nvim_buf_get_name(0)
  vim.fn.writefile(vim.fn.readfile(old), file)
  vim.cmd("e!")
  vim.notify(string.format("File %s restored", vim.fn.fnamemodify(file, ":.")), vim.log.levels.INFO)
end

return M
