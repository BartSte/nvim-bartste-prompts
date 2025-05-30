local global_opts = require("prompts._core.opts")
local run = require("prompts._core.run")

local setup_called = false

--- Creates a Neovim user command handler for a specific prompt type
---@param command string The prompt type to handle (e.g. "docstrings", "refactor")
---@return function Command handler function for Neovim API
local function make_command(command, type)
  return function(args) require("prompts.commands")[type](command, args) end
end

--- Creates user commands for different AI prompt types
--- Registers commands like `AiDocstrings`, `AiTypehints`, etc.
---@see vim.api.nvim_create_user_command
local function make_prompt_commands()
  ---@table List of AI prompt command definitions
  local prompt_commands = {
    { command = "AiDocstrings", type = "edit",   prompt = "docstrings" },
    { command = "AiTypehints",  type = "edit",   prompt = "typehints" },
    { command = "AiRefactor",   type = "edit",   prompt = "refactor" },
    { command = "AiExplain",    type = "output", prompt = "explain" },
    { command = "AiFix",        type = "edit",   prompt = "fix" },
    { command = "AiTests",      type = "edit",   prompt = "unittests" },
  }
  for _, cmd in ipairs(prompt_commands) do
    vim.api.nvim_create_user_command(cmd.command, make_command(cmd.prompt, cmd.type), { range = true })
  end
end

--- Sets up all plugin-related Neovim user commands
--- Creates base commands (AiUndo, AiIsRunning) and prompt-specific commands
local function make_commands()
  local commands = require("prompts.commands")
  vim.api.nvim_create_user_command("AiUndo", commands.undo, {})
  vim.api.nvim_create_user_command("AiIsRunning", commands.is_running, {})
  vim.api.nvim_create_user_command("AiAbort", commands.abort, {})
  make_prompt_commands()
end

--- Verifies required executables are present in PATH
--- Checks for 'prompts' and 'aider' binaries
---@return boolean Result Returns true if all required executables are found, false otherwise
local function check_executables()
  local result = vim.fn.executable("prompts") == 1 and vim.fn.executable("aider") == 1
  if not result then
    vim.notify("Missing required executables: 'prompts' and/or 'aider' must be in PATH", vim.log.levels.ERROR)
  end
  return result
end

--- Initializes the plugin setup and configuration
---@param opts table|nil Configuration options table
---@return nil
---@error Missing AIDER_MODEL environment variable
---@error Missing required executables in PATH
return function(opts)
  if setup_called then
    return
  end
  setup_called = true

  if vim.env["AIDER_MODEL"] == nil then
    vim.notify("AIDER_MODEL environment variable not set. Aborting setup.", vim.log.levels.ERROR)
    return
  end

  opts = opts or {}
  global_opts.update(opts)
  vim.env["AIDER_AUTO_COMMITS"] = "False"
  if not check_executables() then
    return
  end
  make_commands()
end
