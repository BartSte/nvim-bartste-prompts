local M = {}

local commands = require("prompts.commands")

--- Checks for required external executables in PATH
--- Notifies an error and prevents command creation if missing
local function check_executables()
  if vim.fn.executable("prompts") == 0 or vim.fn.executable("aider") == 0 then
    vim.notify("Missing required executables: 'prompts' and/or 'aider' must be in PATH", vim.log.levels.ERROR)
    return
  end
end

--- Creates Neovim user commands for different AI prompt types
--- Commands created: AiDocstrings, AiTypehints, AiRefactor, AiFix, AiTests
--- Each command executes the corresponding prompt type through commands.make()
local function make_prompt_commands()
  local prompt_commands = {
    { name = "AiDocstrings", type = "docstrings" },
    { name = "AiTypehints",  type = "typehints" },
    { name = "AiRefactor",   type = "refactor" },
    { name = "AiFix",        type = "fix" },
    { name = "AiTests",      type = "unittests" },
  }
  for _, cmd in ipairs(prompt_commands) do
    vim.api.nvim_create_user_command(cmd.name, commands.make(cmd.type), { range = true })
  end
end

--- Creates all Neovim user commands for the plugin
--- - AiUndo command for undo functionality
--- - Prompt-based commands created by make_prompt_commands()
local function make_commands()
  vim.api.nvim_create_user_command("AiUndo", commands.undo, {})
  vim.api.nvim_create_user_command("AiIsRunning", commands.is_running, {})
  make_prompt_commands()
end

--- Initializes the plugin configuration
--- @param opts table|nil Optional configuration table (currently unused)
function M.setup(opts)
  opts = opts or {}
  vim.env["AIDER_AUTO_COMMITS"] = "False"
  check_executables()
  make_commands()
end

return M
