local M = {}

local commands = require("bartste-prompts.commands")
local utils = require("bartste-prompts.utils")

function M.setup(opts)
    opts = opts or {}
    -- Set up commands
    vim.api.nvim_create_user_command("PromptDocstrings", commands.docstrings, { range = true })
    vim.api.nvim_create_user_command("PromptTypehints", commands.typehints, { range = true })
    vim.api.nvim_create_user_command("PromptRefactor", commands.refactor, { range = true })
    vim.api.nvim_create_user_command("PromptFix", commands.fix, { range = true })
    vim.api.nvim_create_user_command("PromptTests", commands.unittests, { range = true })

    -- Set up default key mappings if not disabled
    if not opts.disable_keymaps then
        vim.keymap.set("n", "<leader>pd", "<cmd>PromptDocstrings<CR>", { desc = "Add docstrings" })
        vim.keymap.set("n", "<leader>pt", "<cmd>PromptTypehints<CR>", { desc = "Add type hints" })
        vim.keymap.set("n", "<leader>pr", "<cmd>PromptRefactor<CR>", { desc = "Refactor code" })
        vim.keymap.set("n", "<leader>pf", "<cmd>PromptFix<CR>", { desc = "Fix bugs" })
        vim.keymap.set("n", "<leader>pu", "<cmd>PromptTests<CR>", { desc = "Add unit tests" })
    end
end

return M
