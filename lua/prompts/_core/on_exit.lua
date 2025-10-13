local jobs = require("prompts._core.job")
local helpers = require("prompts._core.helpers")
local notifier = require("prompts.notifier").spinner
local history = require("prompts._core.history")

local M = {}

---Create a default exit handler that hides the spinner on completion.
---@param job prompts.Job The job to handle.
---@return fun(...):void Handler function to hide the spinner.
function M.default(job)
  return vim.schedule_wrap(function(obj)
    notifier.hide(job)
    local exit_code = obj and obj.code or -1
    if exit_code ~= 0 then
      vim.notify(string.format("Command failed with exit code: %d", exit_code), vim.log.levels.ERROR)
    else
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
    if exit_code ~= 0 then
      vim.notify(string.format("Command failed with exit code: %d", exit_code), vim.log.levels.ERROR)
      jobs.delete(job.file)
      return
    end

    if helpers.diff(job.file, job.tmp) then
      vim.cmd(string.format("tabnew | e %s | diffsplit %s | set filetype=%s", job.file, job.tmp, job.filetype))
      local tmp_bufnr = vim.fn.bufnr(job.tmp)
      if tmp_bufnr > 0 then
        vim.api.nvim_buf_set_option(tmp_bufnr, "buflisted", false)
        vim.api.nvim_buf_set_option(tmp_bufnr, "bufhidden", "wipe")
      end
    end

    history.save(job)
    jobs.delete(job.file)
  end)
end

return M
