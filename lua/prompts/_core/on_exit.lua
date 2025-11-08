local jobs = require("prompts._core.job")
local helpers = require("prompts._core.helpers")
local notifier = require("prompts.notifier").spinner
local history = require("prompts._core.history")
local log = require("prompts._core.log")

local M = {}

---Create a default exit handler that hides the spinner on completion.
---@param job prompts.Job The job to handle.
---@return fun(...):void Handler function to hide the spinner.
function M.default(job)
  return vim.schedule_wrap(function(obj)
    notifier.hide(job)
    local exit_code = obj and obj.code or -1
    log.debug("Job %s finished with exit code %d", job.command, exit_code)
    if exit_code ~= 0 then
      local message = string.format("Command failed with exit code: %d. The error object is %s", exit_code,
        vim.inspect(obj))
      log.error(message)
      vim.notify(message, vim.log.levels.ERROR)
    else
      log.info("Job %s completed successfully for %s", job.command, job.file)
      log.debug("Saving history for %s", job.file)
      history.save(job)
    end
    jobs.delete(job.file)
  end)
end

---Handle command exit status and cleanup for the "prompts.edit" command.
---@param job prompts.Job The job object representing the edit operation.
---@return fun(...):void A wrapped function invoked on command exit.
function M.edit(job)
  return vim.schedule_wrap(function(obj)
    notifier.hide(job)
    local exit_code = obj and obj.code or -1
    log.debug("Job %s finished with exit code %d", job.command, exit_code)
    if exit_code ~= 0 then
      local message = string.format("Command failed with exit code: %d", exit_code)
      log.error(message)
      vim.notify(message, vim.log.levels.ERROR)
      jobs.delete(job.file)
      return
    end

    if helpers.diff(job.file, job.tmp) then
      log.debug("Differences detected for %s -> %s", job.file, job.tmp)
      vim.cmd(string.format("tabnew | e %s | diffsplit %s | set filetype=%s", job.file, job.tmp, job.filetype))
      local tmp_bufnr = vim.fn.bufnr(job.tmp)
      if tmp_bufnr > 0 then
        vim.api.nvim_buf_set_option(tmp_bufnr, "buflisted", false)
        vim.api.nvim_buf_set_option(tmp_bufnr, "bufhidden", "wipe")
      end
    else
      log.debug("No differences detected for %s", job.file)
    end

    log.debug("Saving history for %s", job.file)
    history.save(job)
    log.debug("Cleaning up job state for %s", job.file)
    jobs.delete(job.file)
  end)
end

return M
