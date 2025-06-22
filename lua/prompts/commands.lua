local core = require("prompts._core")
local opts = require("prompts._core.opts")

local M = {}

--- Run a command that will apply modifications to the current buffer
---@param command string The shell command to execute
---@param args? vim.api.keyset.create_user_command.command_args The command arguments passed in the user command
function M.edit(command, args)
  core.run(command, args, "aider-code", core.on_exit.edit)
end

--- Run a command that generates output to stdout about the current buffer
---@param command string The shell command to execute
---@param args? vim.api.keyset.create_user_command.command_args The command arguments passed in the user command
function M.output(command, args)
  core.run(command, args, "aider-ask", core.on_exit.output)
end

--- Restore the file to its previous state before command execution
---@param file? string Optional path to file to restore (default: current buffer)
---@return nil
function M.undo(file)
  if type(file) ~= "string" then
    file = vim.api.nvim_buf_get_name(0)
  end
  local backup_dir = opts.get().backup_dir
  local abs = vim.fn.fnamemodify(file, ":p")
  local hash = vim.fn.sha256(abs):sub(1, 8)
  local basename = vim.fn.fnamemodify(file, ":t")
  local tmp = string.format("%s/%s-%s", backup_dir, hash, basename)

  if vim.fn.filereadable(tmp) == 0 then
    return vim.notify("No previous version to restore", vim.log.levels.ERROR)
  end

  vim.fn.writefile(vim.fn.readfile(tmp), file)
  vim.cmd("e! " .. file)
  vim.notify(string.format("Restored %s from backup", basename), vim.log.levels.INFO)
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

--- Show output buffer for a job
---@param file? string Optional path to file (default: current buffer)
function M.show_output(file)
  if not file or file == "" then
    file = vim.api.nvim_buf_get_name(0)
  end
  local job = require("prompts._core.job").get(file)

  if job and job.buffer and vim.api.nvim_buf_is_valid(job.buffer) then
    vim.cmd("sbuffer " .. job.buffer)
  else
    vim.notify("No output available for file: " .. file, vim.log.levels.INFO)
  end
end

return M
