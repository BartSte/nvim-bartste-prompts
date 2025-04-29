--- Lualine component for prompts commands integration.
--- Displays a spinner alongside the Aider model name when a command is running.
---@module prompts.lualine
local commands = require("prompts.commands")

--- Spinner frames for the loading animation.
---@type string[]
local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
--- Current index into `spinner_frames`.
---@type number
local spinner_index = 1

--- Module for lualine integration with prompts commands.
--- Provides a spinning icon based on the running state of commands.
---@class prompts.lualine
---@field aider_icon fun():string Lualine component displaying model spinner.
local M = {}

--- Returns a spinning icon if a command is running, otherwise an empty string.
M.aider_icon = {
  --- Returns a spinning icon if a command is running.
  ---@return string spinning icon or empty string
  function()
    if commands.is_running() then
      local frame = spinner_frames[spinner_index]
      spinner_index = spinner_index % #spinner_frames + 1
      local cmd = commands.current_command()
      local file = vim.fn.fnamemodify(commands.current_file(), ":t")
      return string.format("%s %s [%s on %s]", vim.env["AIDER_MODEL"], frame, cmd, file)
    end
    spinner_index = 1
    return ""
  end
}

return M
