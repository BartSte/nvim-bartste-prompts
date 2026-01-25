---@class prompts.JobRegistry
---Manages collection of active prompt jobs with file-based indexing
---@field add fun(job: prompts.Job): boolean Add job to registry, returns false if conflict exists
---@field get fun(file: string): prompts.Job|nil Get job by source file path
---@field delete fun(file: string): nil Remove job tracking and cleanup
local M = {}

local log = require("prompts._core.log")

---@type table<string, prompts.Job>
local jobs = {}

---Add job to registry if no existing job for the file.
---@param job prompts.Job
---@return boolean ok
function M.add(job)
  if jobs[job.file] ~= nil then
    log.warn("Job already running for %s; refusing to start another", job.file)
    return false
  end
  jobs[job.file] = job
  return true
end

---Retrieve job by source file path.
---@param file string Absolute path used as job identifier
---@return prompts.Job? job Registered job instance or nil if not found
function M.get(file)
  return jobs[file]
end

---Remove job tracking entry and cleanup resources.
---Safe to call on non-existent/non-running jobs (no-op)
---@param file string Absolute path used as job identifier
---@return nil
function M.delete(file)
  jobs[file] = nil
  log.debug("Removed job for %s", file)
end

return M
