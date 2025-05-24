local M = {}
M.setup_called = false

local commands = require("prompts.commands")
local default_opts = require("prompts.opts")
local user_opts = {}

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
    vim.api.nvim_create_user_command(cmd.name, commands.make(cmd.type), {
      range = true,
      addr = "lines",  -- Explicitly handle line ranges
    })
  end
end

--- Creates all Neovim user commands for the plugin
--- - AiUndo command for undo functionality
--- - Prompt-based commands created by make_prompt_commands()
local function make_commands()
  vim.api.nvim_create_user_command("AiUndo", commands.undo, {})
  vim.api.nvim_create_user_command("AiIsRunning", commands.is_running, {})
  vim.api.nvim_create_user_command("AiAbort", commands.abort, {})
  make_prompt_commands()
end

--- Initializes the plugin configuration
--- @param opts table|nil Optional configuration table (currently unused)
function M.setup(opts)
  if M.setup_called then
    return
  end
  M.setup_called = true

  if vim.env["AIDER_MODEL"] == nil then
    vim.notify("AIDER_MODEL environment variable not set. Aborting setup.", vim.log.levels.ERROR)
    return
  end

  opts = opts or {}
  user_opts = vim.tbl_deep_extend("force", default_opts, opts)
  vim.env["AIDER_AUTO_COMMITS"] = "False"
  check_executables()
  make_commands()
  M.opts = user_opts
end

return M
