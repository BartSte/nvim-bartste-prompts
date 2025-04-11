local M = {}

local commands = require("prompts.commands")

--- Configures Neovim user commands for AI prompts.
--- @param opts? table Optional configuration options.
function M.setup(opts)
  opts = opts or {}
  vim.api.nvim_create_user_command("AiDocstrings", commands.make("docstrings"), { range = true })
  vim.api.nvim_create_user_command("AiTypehints", commands.make("typehints"), { range = true })
  vim.api.nvim_create_user_command("AiRefactor", commands.make("refactor"), { range = true })
  vim.api.nvim_create_user_command("AiFix", commands.make("fix"), { range = true })
  vim.api.nvim_create_user_command("AiTests", commands.make("unittests"), { range = true })
end

return M
