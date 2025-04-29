local commands = require("prompts.commands")

--- Module for lualine integration with prompts commands.
-- Provides a spinning icon based on the running state of commands.
local M = {}

-- Returns a spinning icon if a command is running, otherwise an empty string.
M.aider_icon = {
  --- Returns a spinning icon if a command is running.
  ---@return string spinning icon or empty string
  function()
    if commands.is_running() then
      return string.format("%s ", vim.env["AIDER_MODEL"])
    end
    return ""
  end
}

return M
