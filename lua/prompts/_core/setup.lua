local global_opts = require("prompts._core.opts")
local history = require("prompts._core.history")
local log = require("prompts._core.log")

local setup_called = false

local function make_backup_dir()
  local dir = global_opts.get().backup_dir
  vim.fn.mkdir(dir, "p")
  log.debug("Ensured backup directory exists at %s", dir)
end

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
    { command = "AiAsk",        type = "ask",    prompt = "ask" },
  }
  for _, cmd in ipairs(prompt_commands) do
    vim.api.nvim_create_user_command(cmd.command, make_command(cmd.prompt, cmd.type), { range = true, nargs = '*' })
    log.debug("Registered %s command (prompt=%s)", cmd.command, cmd.prompt)
  end
end

--- Sets up all plugin-related Neovim user commands
--- Creates base commands (AiUndo, AiIsRunning) and prompt-specific commands
local function make_commands()
  local commands = require("prompts.commands")
  vim.api.nvim_create_user_command("AiUndo", commands.undo, {})
  vim.api.nvim_create_user_command("AiIsRunning", commands.is_running, {})
  vim.api.nvim_create_user_command("AiAbort", commands.abort, {})
  vim.api.nvim_create_user_command("AiCommit", commands.commit, {})
  vim.api.nvim_create_user_command("AiShowOutput", function(opts)
    commands.show_output(opts.args)
  end, { nargs = '?', complete = "file" })
  log.debug("Registered base AI commands")
  make_prompt_commands()
end

--- Verifies required executables are present in PATH
--- Checks for 'prompts' and 'aider' binaries
---@return boolean Result Returns true if all required executables are found, false otherwise
local function check_executables()
  local missing = {}
  if vim.fn.executable("prompts") == 0 then
    table.insert(missing, "prompts")
  end
  if vim.fn.executable("aider") == 0 then
    table.insert(missing, "aider")
  end
  if #missing > 0 then
    local message = string.format("Missing required executables: %s must be in PATH", table.concat(missing, ", "))
    log.error(message)
    vim.notify(message, vim.log.levels.ERROR)
    return false
  end
  log.debug("All required executables available: prompts, aider")
  return true
end

--- Initializes the plugin setup and configuration
---@param opts table|nil Configuration options table
---@return nil
---@error Missing AIDER_MODEL environment variable
---@error Missing required executables in PATH
return function(opts)
  log.debug("prompts.setup invoked")
  if setup_called then
    log.debug("Setup already completed, skipping")
    return
  end
  setup_called = true

  opts = opts or {}
  global_opts.update(opts)
  local config = global_opts.get()
  log.setup(config)

  if vim.env["AIDER_MODEL"] == nil then
    local message = "AIDER_MODEL environment variable not set. Aborting setup."
    log.error(message)
    vim.notify(message, vim.log.levels.ERROR)
    return
  end

  vim.env["AIDER_AUTO_COMMITS"] = "False"
  log.debug("Disabled aider auto commits")

  if not check_executables() then
    return
  end

  make_backup_dir()
  log.debug("Backup directory ready at %s", config.backup_dir)

  history.setup()
  log.debug("History storage initialised at %s", config.history_dir)

  make_commands()
  log.debug("Command registration completed")

  log.info("prompts setup completed")
end
