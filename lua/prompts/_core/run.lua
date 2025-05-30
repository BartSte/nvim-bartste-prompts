---Build command table for job execution
---@param job prompts.Job
---@return string[]
local function make_cmd(job)
  local core = require("prompts._core")
  return {
    "prompts", job.command, job.file,
    "--filetype", job.filetype,
    "--action", "aider",
    "--loglevel", core.opts.get().loglevel,
    "--userprompt", job.userprompt
  }
end

--- Execute a prompts job by preparing the environment and starting the process.
--- Reads the current buffer, writes it to a temporary copy, and invokes the prompts CLI.
---
---@param command string The command to dispatch to the prompts CLI
---@param args string[] List of arguments to pass to the job
---@param on_exit fun(job: prompts.Job)? Optional callback invoked upon job completion
---@return nil
return function(command, args, on_exit)
  local core = require("prompts._core")
  local notifier = require("prompts.notifier")
  local file =vim.api.nvim_buf_get_name(0)
  local filetype = vim.bo.filetype

  local job = core.job.new(command, file, filetype, args)

  if job then
    local file_content =  vim.fn.readfile(file)
    vim.fn.writefile(file_content, job.tmp)

    local cmd = make_cmd(job)
    on_exit = on_exit or core.on_exit.default
    job.process = vim.system(cmd, on_exit(job))
    notifier.spinner.show(job)

  else
    vim.notify("A job is already running for file " .. file, vim.log.levels.ERROR)
  end
end
