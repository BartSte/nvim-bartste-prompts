local notifier = require("snacks").notifier

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

--- Start displaying the spinner notification.
---@return nil
function M.spinner.show(cmd, file)
  local opts = require("prompts").opts
  if not opts.notify then
    return
  end
  if M.spinner.timer then
    return
  end
  M.spinner.timer = vim.loop.new_timer()
  M.spinner.timer:start(0, M.spinner.interval, vim.schedule_wrap(function()
    local frame = M.spinner.frames[M.spinner.index]
    M.spinner.index = M.spinner.index % #M.spinner.frames + 1
    local msg = string.format("%s: %s on %s", vim.env["AIDER_MODEL"], cmd, file)
    notifier.notify(msg, "info", { id = M.spinner.id, icon = frame, timeout = false })
  end))
end

--- Stop and hide the spinner notification, resetting its state.
---@return nil
function M.spinner.hide()
  local opts = require("prompts").opts
  if not opts.notify then
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
