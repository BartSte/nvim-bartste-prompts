local log = require("prompts._core.log")
local runner = require("prompts._core.runner")

--- Execute a prompts job by preparing the environment and starting the process
--- Reads the current buffer, writes it to a temporary copy, and invokes the prompts CLI
---@param command string The command to dispatch to the prompts CLI
---@param args string[] List of arguments to pass to the job
---@param action string The `prompts <command> --action <action>` value
---@param on_exit fun(job: prompts.Job)? Optional callback invoked upon job completion
---@return nil
local function run(command, args, action, on_exit)
  local core = require("prompts._core")
  local file = vim.api.nvim_buf_get_name(0)
  local filetype = vim.bo.filetype
  log.info("Starting %s (%s) for %s", tostring(command), tostring(action), file)
  local job = core.job.new(command, file, filetype, action, args)
  if not runner.start(job, on_exit) then
    log.warn("Job already running for %s", file)
    vim.notify("A job is already running for file " .. file, vim.log.levels.ERROR)
    return
  end
end

return run
