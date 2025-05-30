local jobs = require("prompts._core.job")
local helpers = require("prompts._core.helpers")
local notifier = require("prompts.notifier").spinner

local M = {}

---Create a default exit handler that hides the spinner on completion.
---@param job prompts.Job The job to handle.
---@return fun(...):void Handler function to hide the spinner.
function M.default(job)
  return vim.schedule_wrap(function(...) notifier.hide(job) end)
end

---Handle command exit status and cleanup for the "prompts.edit" command.
---@param job prompts.Job The job object representing the edit operation.
---@return fun(...):void A wrapped function invoked on command exit.
function M.edit(job)
  return vim.schedule_wrap(function(obj)
    require("prompts.notifier").spinner.hide(job)
    if obj.code ~= 0 then
      vim.notify(string.format("Command failed with exit code: %d", obj.code), vim.log.levels.ERROR)
      vim.notify(string.format("stderr: %s", obj.stderr), vim.log.levels.ERROR)
      vim.notify(string.format("stdout: %s", obj.stdout), vim.log.levels.INFO)
    else
      if helpers.diff(job.file, job.filecopy) then
        vim.cmd(string.format("tabnew | e %s | diffsplit %s | set filetype=%s", job.file, job.filecopy, job.filetype))
      end
      jobs.delete(job.file)
    end
  end)
end

---Handle command exit status and cleanup for the "prompts.output" command.
---@param job prompts.Job The job object representing the output command.
---@return fun(...):void A function invoked on command exit and cleanup.
function M.output(job)
  return vim.schedule_wrap(function(obj)
    notifier.hide(job)
    if obj.code ~= 0 then
      vim.notify(string.format("Explain failed: %s", obj.stderr), vim.log.levels.ERROR)
    else
      vim.notify(obj.stdout, vim.log.levels.INFO)
    end
    jobs.delete(job.file)
  end)
end

return M
