local M = {}

---@class State
---@field lock boolean Whether a command is currently running
---@field command string The currently executing command name
---@field file string Path to the original file being processed
---@field file_copy string Temporary backup file path
local State = {
  lock = false,
  command = '',
  file = '',
  file_copy = vim.fn.tempname()
}

--- Handles command execution cleanup and notification
---@param file string Path to the file being processed
---@return function Function to handle command completion
local function on_exit(file)
  vim.fn.writefile(vim.fn.readfile(file), State.file_copy)
  return vim.schedule_wrap(function(obj)
    State.lock = false
    if obj.code ~= 0 then
      vim.notify(string.format("Command failed with exit code: %d", obj.code), vim.log.levels.ERROR)
      vim.notify(string.format("stderr: %s", obj.stderr), vim.log.levels.ERROR)
      vim.notify(string.format("stdout: %s", obj.stdout), vim.log.levels.INFO)
    else
      vim.notify("Command succeeded. Run :AiUndo to undo the changes.", vim.log.levels.INFO)
      vim.cmd(string.format("tabnew | e %s | diffsplit %s | set filetype=%s", file, State.file_copy, vim.bo.filetype))
    end
  end)
end

--- Creates a command wrapper function for key mappings/callbacks
---@param command string The CLI command to execute
---@return fun(): nil # Function that executes the command when called
function M.make(command)
  return function()
    M.run(command)
  end
end

--- Executes a command with proper error handling and state management
---@param command string The CLI command to execute
---@return nil
function M.run(command)
  if State.lock then
    vim.notify(string.format("Another command '%s' is already running", State.command), vim.log.levels.WARN)
  end

  State.lock = true
  State.command = command
  State.file = vim.api.nvim_buf_get_name(0) -- Store original file path
  local filetype = vim.bo.filetype
  local cmd = { "prompts", command, State.file, "--filetype", filetype, "--action", "aider" }
  vim.notify(string.format("Running command %s", command), vim.log.levels.INFO)
  vim.system(cmd, {}, on_exit(State.file))
end

function M.undo()
  if State.file_copy == '' or vim.fn.filereadable(State.file_copy) == 0 then
    vim.notify("No previous version to restore", vim.log.levels.ERROR)
    return
  end

  if not State.file or vim.fn.filereadable(State.file) == 0 then
    vim.notify("Original file path is no longer valid", vim.log.levels.ERROR)
    return
  end

  vim.fn.writefile(vim.fn.readfile(State.file_copy), State.file)
  vim.cmd("e! " .. State.file)
  vim.notify(string.format("File %s restored", vim.fn.fnamemodify(State.file, ":.")), vim.log.levels.INFO)
end

function M.is_running()
  return State.lock
end

--- Returns the currently running command name, or empty string.
function M.current_command()
  return State.command
end

--- Returns the file path on which the current command is running, or empty string.
function M.current_file()
  return State.file
end

return M
