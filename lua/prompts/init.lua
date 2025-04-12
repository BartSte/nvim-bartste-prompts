local M = {}

local commands = require("prompts.commands")

--- Checks if required executables ('prompts' and 'aider') are available in PATH
--- Shows an error notification if any executables are missing
---@return nil
local function check_executables()
  if vim.fn.executable("prompts") == 0 or vim.fn.executable("aider") == 0 then
    vim.notify("Missing required executables: 'prompts' and/or 'aider' must be in PATH", vim.log.levels.ERROR)
    return
  end
end

--- Creates Neovim user commands for AI code operations
--- Maps commands like AiDocstrings, AiTypehints, etc. to their implementations
---@return nil
local function set_mappings()
  local command_mappings = {
    { name = "AiDocstrings", type = "docstrings" },
    { name = "AiTypehints",  type = "typehints" },
    { name = "AiRefactor",   type = "refactor" },
    { name = "AiFix",        type = "fix" },
    { name = "AiTests",      type = "unittests" },
  }
  for _, cmd in ipairs(command_mappings) do
    vim.api.nvim_create_user_command(cmd.name, commands.make(cmd.type), { range = true })
  end
end

--- Initializes the plugin configuration and sets up command mappings
---@param opts? table Optional configuration table (currently unused)
---@return nil
function M.setup(opts)
  opts = opts or {}
  check_executables()
  set_mappings()
end

return M
