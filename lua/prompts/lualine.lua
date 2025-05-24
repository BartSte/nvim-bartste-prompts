local commands = require("prompts.commands")

--- A sequence of spinner frames used to animate the lualine spinner component.
---@type string[]
local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
--- Current index in spinner_frames for the animated spinner.
---@type integer
local spinner_index = 1

--- Lualine integration module for displaying Aider prompts in the statusline.
---@class prompts.lualine
local M = {}

--- Lualine component for the Aider prompt spinner and command info.
---@type table[]
M.aider_icon = {
  --- Generates the formatted component string for lualine.
  ---@return string the formatted segment or empty if no command is running.
  function()
    if commands.is_running() then
      local frame = spinner_frames[spinner_index]
      spinner_index = spinner_index % #spinner_frames + 1
      return string.format("%s %s", vim.env["AIDER_MODEL"], frame)
    end
    spinner_index = 1
    return ""
  end
}

return M
