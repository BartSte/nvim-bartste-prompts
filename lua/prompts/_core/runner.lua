local notifier = require("prompts.notifier")
local outputbuf = require("prompts._core.outputbuf")
local log = require("prompts._core.log")
local registry = require("prompts._core.registry")

--- Create a backup copy of the current file
---@param job prompts.Job The job object
---@param file string The path of the file to back up
---@return boolean success True if the backup was created successfully
local function make_backup(job, file)
  local ok, file_content = pcall(vim.fn.readfile, file)
  if not ok then
    log.error("Failed to read %s for backup: %s", file, file_content)
    return false
  end
  local write_ok, write_err = pcall(vim.fn.writefile, file_content, job.tmp)
  if not write_ok then
    log.error("Failed to write backup %s: %s", job.tmp, write_err)
    return false
  end
  log.debug("Created backup for %s at %s", file, job.tmp)
  return true
end

--- Build command table for job execution
---@param job prompts.Job The job object containing command details
---@return string[] The command table for the job
local function make_cmd(job)
  local core = require("prompts._core")
  return {
    "prompts", job.command,
    "--files", job.file,
    "--filetype", job.filetype,
    "--loglevel", core.opts.get().loglevel,
    "--user", job.userprompt,
    "--action", job.action
  }
end

--- Create a writer function for job output
---@param job prompts.Job The job object
---@return fun(process: any, data: string) The writer function
local function make_writer(job)
  return function(_, data)
    outputbuf.append(job.buffer, data)
  end
end

local M = {}

--- Execute a prompts job by preparing the environment and starting the process
--- Reads the current buffer, writes it to a temporary copy, and invokes the prompts CLI
---@param job prompts.Job The job object to execute
---@param on_exit fun(job: prompts.Job)? Optional callback invoked upon job completion
---@return boolean ok
function M.start(job, on_exit)
  if not registry.add(job) then
    return false
  end

  if not make_backup(job, job.file) then
    local message = string.format("Failed to create backup for %s; aborting job", job.file)
    log.error(message)
    vim.notify(message, vim.log.levels.ERROR)
    registry.delete(job.file)
    return false
  end

  job.buffer = outputbuf.new(job.file)
  local cmd = make_cmd(job)
  local opts = {
    stdout = make_writer(job),
    stderr = make_writer(job),
    text = true
  }
  local core = require("prompts._core")
  on_exit = on_exit or core.on_exit.default
  log.info("Executing command: %s for job %s", table.concat(cmd, " "), job.file)
  job.process = vim.system(cmd, opts, on_exit(job))
  local pid = "?"
  if job.process then
    local ok, value = pcall(function()
      return job.process:pid()
    end)
    if ok and value then
      pid = value
    end
  end
  log.info("Prompts job running (pid=%s) for %s", pid, job.file)
  notifier.spinner.show(job)
  return true
end

return M
