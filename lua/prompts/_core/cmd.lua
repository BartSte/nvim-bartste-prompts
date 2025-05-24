local M = {}

---@type prompts.Opts
local opts = require("prompts._core.opts")

---Build command table for job execution
---@param job prompts.Job
---@return string[]
function M.make(job)
  return {
    "prompts", job.command, job.file,
    "--filetype", job.filetype,
    "--action", "aider",
    "--loglevel", opts.get().loglevel,
    "--userprompt", job.userprompt
  }
end

return M
