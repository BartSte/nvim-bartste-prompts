local global_opts = require("prompts._core.opts")

local setup_called = false

--- Creates a Neovim user command handler for a specific prompt type
---@param command string The prompt type to handle (e.g. "docstrings", "refactor")
---@return function Command handler function for Neovim API
local function make_command(command)
  return function(args)
    require("prompts.commands").run(command, args)
  end
end

--- Creates user commands for different AI prompt types
--- Registers commands like `AiDocstrings`, `AiTypehints`, etc.
---@see vim.api.nvim_create_user_command
local function make_prompt_commands()
  ---@table List of AI prompt command definitions
  local prompt_commands = {
    { name = "AiDocstrings", type = "docstrings" },
    { name = "AiTypehints",  type = "typehints" },
    { name = "AiRefactor",   type = "refactor" },
    { name = "AiFix",        type = "fix" },
    { name = "AiTests",      type = "unittests" },
  }
  for _, cmd in ipairs(prompt_commands) do
    vim.api.nvim_create_user_command(cmd.name, make_command(cmd.type), {
      range = true,
    })
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
---@return boolean|nil Returns nil if checks fail, shows error notification
local function check_executables()
  if vim.fn.executable("prompts") == 0 or vim.fn.executable("aider") == 0 then
    vim.notify("Missing required executables: 'prompts' and/or 'aider' must be in PATH", vim.log.levels.ERROR)
    return
  end
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
  check_executables()
  make_commands()
end


