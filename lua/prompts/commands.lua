local core = require("prompts._core")

local M = {}

--- Run a command that will apply modifications to the current buffer
---@param command string The shell command to execute
---@param args? vim.api.keyset.create_user_command.command_args The command arguments passed in the user command
function M.edit(command, args)
  core.run(command, args, core.on_exit.edit)
end

--- Run a command that generates output to stdout about the current buffer
---@param command string The shell command to execute
---@param args? vim.api.keyset.create_user_command.command_args The command arguments passed in the user command
function M.output(command, args)
  core.run(command, args, core.on_exit.output)
end

--- Restore the file to its previous state before command execution
---@param file? string Optional path to file to restore (default: current buffer)
---@return nil
function M.undo(file)
  if type(file) ~= "string" then
    file = vim.api.nvim_buf_get_name(0)
  end
  local job = core.job.get(file)
  if job == nil or job.tmp == '' or vim.fn.filereadable(job.tmp) == 0 then
    vim.notify("No previous version to restore", vim.log.levels.ERROR)
    return
  end

  if not job.file or vim.fn.filereadable(job.file) == 0 then
    vim.notify("Original file path is no longer valid", vim.log.levels.ERROR)
    return
  end

  vim.fn.writefile(vim.fn.readfile(job.tmp), job.file)
  vim.cmd("e! " .. job.file)
  vim.notify(string.format("File %s restored", vim.fn.fnamemodify(job.file, ":.")), vim.log.levels.INFO)
end

--- Check if there's an active job for the given file
---@param file? string Optional path to check (default: current buffer)
---@return boolean
function M.is_running(file)
  if type(file) ~= "string" then
    file = vim.api.nvim_buf_get_name(0)
  end
  return core.job.get(file) ~= nil
end

--- Abort any running job for the given file
---@param file? string Optional path to check (default: current buffer)
---@return nil
function M.abort(file)
  if type(file) ~= "string" then
    file = vim.api.nvim_buf_get_name(0)
  end
  local job = core.job.get(file)
  if not job or not job.process then
    vim.notify("No job to abort for this file", vim.log.levels.ERROR)
    return
  end

  if job.process then
    job.process:kill()
    require("prompts.notifier").spinner.hide(job)
    core.job.delete(file)
  end
end

return M
