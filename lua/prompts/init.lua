local M = {}

local commands = require("prompts.commands")

local function check_executables()
  if vim.fn.executable("prompts") == 0 or vim.fn.executable("aider") == 0 then
    vim.notify("Missing required executables: 'prompts' and/or 'aider' must be in PATH", vim.log.levels.ERROR)
    return
  end
end

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

function M.setup(opts)
  opts = opts or {}
  check_executables()
  set_mappings()
end

return M
