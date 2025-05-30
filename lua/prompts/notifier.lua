local notifier = require("snacks").notifier
local opts = require("prompts._core.opts")

--- A notifier module that displays and hides a spinner notification.
---@module prompts.notifier

local M = {}
--- Spinner namespace containing spinner state and functions.
---@class prompts.notifier.Spinner
---@field frames string[] Animation frames for the spinner
---@field spinners table<string, {index: number}> Table of active job spinners keyed by file
---@field timer userdata|nil Shared timer handle from luv (vim.loop)
---@field interval number Timer interval in milliseconds
---@field id string Notification identifier
M.spinner = {}
M.spinner.frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
M.spinner.spinners = {}
M.spinner.timer = nil
M.spinner.interval = 100
M.spinner.id = "aider_prompt_jobs"

--- Starts and updates a spinner notification for an active job.
--- Checks notify option before creating timer.
---@param job prompts.Job The job instance associated with the spinner
---@return nil
function M.spinner.show(job)
  if not opts.get().notify then
    return
  end
  -- Add job to spinners table if not already present
  if not M.spinner.spinners[job.file] then
    M.spinner.spinners[job.file] = {
      index = 1,
      filename = vim.fn.fnamemodify(vim.fn.expand(job.file), ":t"),
      command = job.command
    }
  end

  -- Start timer if not already running
  if not M.spinner.timer then
    M.spinner.timer = vim.loop.new_timer()
    M.spinner.timer:start(0, M.spinner.interval, vim.schedule_wrap(function()
      local messages = {}
      for file, spinner in pairs(M.spinner.spinners) do
        spinner.index = spinner.index % #M.spinner.frames + 1
        local frame = M.spinner.frames[spinner.index]
        table.insert(messages, string.format("%s %s: %s", frame, spinner.command, spinner.filename))
      end

      local msg = table.concat(messages, "\n")
      notifier.notify(msg, "info", {
        id = M.spinner.id,
        icon = "󰚥",
        timeout = false,
        title = string.format("%s - %d active jobs", vim.env["AIDER_MODEL"], #messages)
      })
    end)
    )
  end
end

--- Stops and hides the spinner notification.
--- Resets timer and animation state. Safe to call even when inactive.
---@return nil
function M.spinner.hide(job)
  if not opts.get().notify or not job or not M.spinner.spinners[job.file] then
    return
  end

  -- Remove the job from spinners
  M.spinner.spinners[job.file] = nil

  -- Stop timer if no more jobs
  if vim.tbl_isempty(M.spinner.spinners) and M.spinner.timer then
    M.spinner.timer:stop()
    M.spinner.timer:close()
    M.spinner.timer = nil
    notifier.hide(M.spinner.id)
  end
end

return M
