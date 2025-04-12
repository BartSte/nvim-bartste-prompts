local M = {}

local function get_current_buffer_info()
  local file = vim.api.nvim_buf_get_name(0)
  local filetype = vim.bo.filetype
  return file, filetype
end

local function reload_buffer(file)
  --TODO
end

--- Creates a command function that runs a given command on the current buffer file.
---@param command string The command to run.
---@return function A function without parameters that executes the command.
function M.make(command)
  return function()
    local file, ft = get_current_buffer_info()
    M.run(command, file, ft)
    reload_buffer(file)
  end
end

--- Callback function executed when a system command exits.
---@param obj table The exit information with fields: code (number), stdout (string), stderr (string)
local function on_exit(obj)
  if obj.code ~= 0 then
    vim.notify(string.format("Command failed with exit code: %d", obj.code), vim.log.levels.ERROR)
    vim.notify(string.format("stderr: %s", obj.stderr), vim.log.levels.ERROR)
    vim.notify(string.format("stdout: %s", obj.stdout), vim.log.levels.INFO)
  else
    vim.notify("Command succeeded", vim.log.levels.INFO)
  end
end


--- Executes a system command using prompts-aider with the given parameters.
---@param command string The command identifier.
---@param file string The current file name.
---@param ft string The filetype.
function M.run(command, file, ft)
  local cmd = { "prompts", command, file, "--filetype", ft, "--action", "aider" }
  vim.notify(string.format("Running: %s", table.concat(cmd, " ")))
  vim.system(cmd, {}, on_exit)
end

return M
