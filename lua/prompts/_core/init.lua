--- Core module that should not be used outside of this package.
---@class prompts.Core
local M = {
  run = require("prompts._core.run"),
  job = require("prompts._core.job"),
  on_exit = require("prompts._core.on_exit"),
  userprompt = require("prompts._core.userprompt"),
  opts = require("prompts._core.opts"),
  setup = require("prompts._core.setup"),
}
return M
