local M = {}

local commands = require("prompts.commands")

function M.setup(opts)
    opts = opts or {}
    vim.api.nvim_create_user_command("PromptDocstrings", commands.docstrings, { range = true })
    vim.api.nvim_create_user_command("PromptTypehints", commands.typehints, { range = true })
    vim.api.nvim_create_user_command("PromptRefactor", commands.refactor, { range = true })
    vim.api.nvim_create_user_command("PromptFix", commands.fix, { range = true })
    vim.api.nvim_create_user_command("PromptTests", commands.unittests, { range = true })

end

return M
