local M = {}

local active_command = ''
local old = vim.fn.tempname()

--- Handles command execution cleanup and notification
---@param file string Path to the file being processed
---@return function Function to handle command completion
local function on_exit(file)
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
    active_command = ''
  end)
end

--- Creates a command wrapper function for use in mappings/callbacks
---@param command string The command to execute when called
---@return function Function suitable for mappings/callbacks
function M.make(command)
  return function()
    M.run(command)
  end
end

--- Executes a command with proper error handling and state management
---@param command string The command to execute
function M.run(command)
  if active_command ~= '' then
    vim.notify(string.format("Another command '%s' is already running", active_command), vim.log.levels.WARN)
  end

  active_command = command
  M.original_file = vim.api.nvim_buf_get_name(0)  -- Store original file path
  local file = M.original_file
  local filetype = vim.bo.filetype
  local cmd = { "prompts", command, file, "--filetype", filetype, "--action", "aider" }
  vim.notify(string.format("Running command %s", command), vim.log.levels.INFO)
  vim.system(cmd, {}, on_exit(file))
end

--- Restores the previous version of the file
--- Validates existing backup file before attempting restoration
function M.undo()
  if old == '' or vim.fn.filereadable(old) == 0 then
    vim.notify("No previous version to restore", vim.log.levels.ERROR)
    return
  end

  -- Use the stored original file path from when the command was run
  if not M.original_file or vim.fn.filereadable(M.original_file) == 0 then
    vim.notify("Original file path is no longer valid", vim.log.levels.ERROR)
    return
  end
  
  vim.fn.writefile(vim.fn.readfile(old), M.original_file)
  vim.cmd("e! " .. M.original_file)  -- Force reload the original file
  vim.notify(string.format("File %s restored", vim.fn.fnamemodify(M.original_file, ":.")), vim.log.levels.INFO)
end

return M
