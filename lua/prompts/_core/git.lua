local log = require("prompts._core.log")

--- Utility functions for interacting with Git within the prompts core module.
---@class PromptsGitModule
---@field diff fun(args?: string[]):nil Collects git diff output and dispatches related notifications
local M = {}

--- Collect the git diff with optional arguments and handle notifications.
---@param ... string[] Optional arguments to pass to the git diff command
---@return nil
function M.diff(...)
    local cmd = vim.list_extend({ "git", "diff" }, { ... })
    local diff = vim.fn.system(cmd)

    if vim.v.shell_error ~= 0 then
        local message = "Failed to collect git diff:\n" .. diff
        log.error(message)
        vim.notify(message, vim.log.levels.ERROR)
        return
    end

    return vim.trim(diff)
end

function M.commit(...)
    local cmd = vim.list_extend({ "git", "commit" }, { ... })
    local result = vim.fn.system(cmd)

    if vim.v.shell_error ~= 0 then
        local message = "Git commit failed:\n" .. result
        log.error(message)
        vim.notify(message, vim.log.levels.ERROR)
        return
    end

    log.info("Git commit successful")
    vim.notify("Git commit successful", vim.log.levels.INFO)
end

return M
