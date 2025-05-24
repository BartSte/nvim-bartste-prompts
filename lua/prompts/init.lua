--- Main entry point for prompts.nvim module
--- Provides access to all core components and public interfaces
---@class Prompts
---@field commands table Command-related functionality (create/run/manage prompts)
---@field lualine table Integration with lualine statusline component
---@field notifier table Notification and progress tracking utilities
---@field setup function Module configuration setup function
---@field get_opts function Get current configuration options
return {
  commands = require("prompts.commands"),
  get_opts = require("prompts._core.opts").get,
  lualine = require("prompts.lualine"),
  notifier = require("prompts.notifier"),
  setup = require("prompts._core.setup"),
}
