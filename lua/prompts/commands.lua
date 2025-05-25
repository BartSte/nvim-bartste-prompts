local core = require("prompts._core")

local M = {}

--- Run a command with arguments on the current buffer's content
---@param command string The shell command to execute
---@param args? vim.api.keyset.create_user_command.command_args The command arguments passed in the user command
function M.run(command, args)
  local file = vim.api.nvim_buf_get_name(0)
  local job = core.job.new(command, file, vim.bo.filetype, args)
  if not job then
    vim.notify("A job is already running for file " .. file, vim.log.levels.ERROR)
    return
  end

  local cmd = core.cmd.make(job)
  vim.fn.writefile(vim.fn.readfile(job.file), job.filecopy)
  job.process = vim.system(cmd, core.on_exit(job))
  require("prompts.notifier").spinner.show(job)
end

--- Restore the file to its previous state before command execution
---@param file? string Optional path to file to restore (default: current buffer)
---@return nil
function M.undo(file)
  if type(file) ~= "string" then
    file = vim.api.nvim_buf_get_name(0)
  end
  local job = core.job.get(file)
  if job == nil or job.filecopy == '' or vim.fn.filereadable(job.filecopy) == 0 then
    vim.notify("No previous version to restore", vim.log.levels.ERROR)
    return
  end

  if not job.file or vim.fn.filereadable(job.file) == 0 then
    vim.notify("Original file path is no longer valid", vim.log.levels.ERROR)
    return
  end

  vim.fn.writefile(vim.fn.readfile(job.filecopy), job.file)
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
  end
end

return M
