local M = {}

--- Creates a command function that runs a given command on the current buffer file.
---@param command string The command to run.
---@return function A function without parameters that executes the command.
function M.make(command)
  return function()
    local file = vim.api.nvim_buf_get_name(0)
    local ft = vim.bo.filetype
    M.run(command, file, ft)
  end
end

--- Callback function executed when a system command exits.
---@param obj table The exit information with fields: code (number), stdout (string), stderr (string)
local function on_exit(obj)
  if obj.code ~= 0 then
    vim.notify("Command failed with exit code: " .. obj.code, vim.log.levels.ERROR)
    vim.notify("stderr: " .. obj.stderr, vim.log.levels.ERROR)
    vim.notify("stdout: " .. obj.stdout, vim.log.levels.INFO)
  else
    vim.notify("Command succeeded", vim.log.levels.INFO)
  end
end


--- Executes a system command using prompts-aider with the given parameters.
---@param command string The command identifier.
---@param file string The current file name.
---@param ft string The filetype.
function M.run(command, file, ft)
  local cmd = { "prompts-aider", command, file, "--filetype", ft }
  vim.notify("Running: " .. table.concat(cmd, " "))
  vim.system(cmd, {}, on_exit)
end

return M
