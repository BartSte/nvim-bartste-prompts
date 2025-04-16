local M = {}

local lock = ''

local function schedule_on_exit(file)
  ---@param obj table Process completion object {code: number, stdout: string, stderr: string}
  return vim.schedule_wrap(function(obj)
    if obj.code ~= 0 then
      vim.notify(string.format("Command failed with exit code: %d", obj.code), vim.log.levels.ERROR)
      vim.notify(string.format("stderr: %s", obj.stderr), vim.log.levels.ERROR)
      vim.notify(string.format("stdout: %s", obj.stdout), vim.log.levels.INFO)
    else
      vim.notify("Command succeeded", vim.log.levels.INFO)
      local cmd = string.format("tabnew | e %s", file)
      if vim.g.loaded_fugitive == 1 then
        cmd = cmd .. ' | Gvdiffsplit !~1'
      else
        vim.notify("Fugitive not loaded, no diff view available.", vim.log.levels.WARN)
      end
      vim.cmd(cmd)
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

return M
