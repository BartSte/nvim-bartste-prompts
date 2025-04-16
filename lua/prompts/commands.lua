local M = {}

local lock = ''
local old = vim.fn.tempname()

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

--- Executes a system command with concurrency control
---@param command string Command identifier to execute
---@return nil
local function run(command)
  -- Implements a global lock to prevent concurrent command executions
  -- Notifies command status through vim.notify
  -- Creates new buffer tab on success when fugitive is available
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
---@return boolean # True if execution started successfully
---@return any # Error message if execution failed
function M.run(command)
  -- Wraps run() in pcall for error handling
  -- Manages lock state cleanup on failure
  local ok, _ = pcall(run, command)
  if not ok then
    vim.notify(string.format("Command %s failed", command), vim.log.levels.ERROR)
    lock = ''
  end
end

--- Creates a command closure for deferred execution
---@param command string Command identifier to bind
---@return function # Parameterless function that triggers command execution
function M.make(command)
  -- Returns a function that can be used as a callback or mapping target
  -- Example: vim.keymap.set('n', '<leader>cf', M.make('format'))
  return function()
    M.run(command)
  end
end

--- Restores the current file from the stored old version
---@return nil
function M.undo()
  if old == '' or vim.fn.filereadable(old) == 0 then
    vim.notify("No previous version to restore", vim.log.levels.ERROR)
    return
  end

  local file = vim.api.nvim_buf_get_name(0)
  vim.fn.writefile(vim.fn.readfile(old), file)
  vim.cmd("e!")
  vim.notify(string.format("File %s restored", file), vim.log.levels.INFO)
end

return M
