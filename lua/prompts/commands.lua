local M = {}

---Get information about the current buffer
---@return string file Current buffer's file name
---@return string filetype Current buffer's file type
local function get_current_buffer_info()
  local file = vim.api.nvim_buf_get_name(0)
  local filetype = vim.bo.filetype
  return file, filetype
end

---Reload the specified buffer in the current window
---@param file string The file path to reload from disk
local function reload_buffer(file)
  local buf = vim.fn.bufnr(file)
  if buf ~= -1 and vim.fn.bufloaded(buf) == 1 then
    vim.api.nvim_buf_delete(buf, { force = true })
  end

  if vim.api.nvim_get_current_buf() == buf then
    vim.api.nvim_set_current_buf(vim.api.nvim_create_buf(true, false))
  end

  vim.cmd("silent! edit! " .. vim.fn.fnameescape(file))
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
