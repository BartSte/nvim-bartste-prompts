local jobs = require("prompts._core.job")
local helpers = require("prompts._core.helpers")

---Handle command exit status and cleanup
---@param job prompts.Job
---@return fun(...)
return function(job)
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
