local notifier = require("snacks").notifier
local opts = require("prompts._core.opts")

--- A notifier module that displays and hides a spinner notification.
---@module prompts.notifier

local M = {}
--- Spinner namespace containing spinner state and functions.
---@class prompts.notifier.Spinner
---@field frames string[] Animation frames for the spinner
---@field index number Current frame index
---@field id string Notification identifier
---@field timer userdata|nil Timer handle from luv (vim.loop)
---@field interval number Timer interval in milliseconds
M.spinner = {}
M.spinner.frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
M.spinner.index = 1
M.spinner.id = "aider_prompt"
M.spinner.timer = nil
M.spinner.interval = 100

--- Starts and updates a spinner notification for an active job.
--- Checks notify option before creating timer.
---@param job Job The job instance associated with the spinner
---@return nil
function M.spinner.show(job)
  if not opts.get().notify then
    return
  end
  if M.spinner.timer then
    return
  end
  M.spinner.timer = vim.loop.new_timer()
  M.spinner.timer:start(0, M.spinner.interval, vim.schedule_wrap(function()
    local frame = M.spinner.frames[M.spinner.index]
    M.spinner.index = M.spinner.index % #M.spinner.frames + 1
    local filename = vim.fn.fnamemodify(vim.fn.expand(job.file), ":t")
    local msg = string.format("%s: %s on %s", vim.env["AIDER_MODEL"], job.command, filename)
    notifier.notify(msg, "info", { id = M.spinner.id, icon = frame, timeout = false })
  end))
end

--- Stops and hides the spinner notification.
--- Resets timer and animation state. Safe to call even when inactive.
---@return nil
function M.spinner.hide()
  if not opts.get().notify then
    return
  end
  if M.spinner.timer then
    M.spinner.timer:stop()
    M.spinner.timer:close()
    M.spinner.timer = nil
  end
  M.spinner.index = 1
  notifier.hide(M.spinner.id)
end

return M
