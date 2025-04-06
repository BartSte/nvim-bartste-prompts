local M = {}
local utils = require("prompts.utils")

--- Internal function to handle prompt command execution
---@param command string The subcommand to run
---@param files table List of files to process
local function run_prompt_command(command, files)
    if #files == 0 then
        files = { vim.api.nvim_buf_get_name(0) }
    end

    local original = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    -- Show transient notification at top right and store reference
    local notif_id = vim.notify(" Processing... ⌛ ", vim.log.levels.INFO, {
        title = "prompts.nvim",
        timeout = false,
        on_close = function() end
    })

    utils.run_prompt(command, files, function(result, err)
        -- Clear progress notification using stored ID
        vim.schedule(function()
            pcall(vim.notify_delete, notif_id)
        end)
        if not result then
            vim.notify("Error: " .. err, vim.log.levels.ERROR)
            return
        end

        local modified = {}
        for _, chunk in ipairs(result) do
            vim.list_extend(modified, vim.split(chunk, "\n"))
        end

        vim.schedule(function()
            local orig_buf, mod_buf = utils.show_diff(original, modified)

            if utils.prompt_user_accept() then
                vim.api.nvim_buf_set_lines(0, 0, -1, false, modified)
                vim.schedule(function()
                    vim.cmd("Gvdiffsplit!")
                    vim.notify("Changes applied", vim.log.levels.INFO)
                end)
            else
                vim.notify("Changes discarded", vim.log.levels.WARN)
            end

            vim.schedule(function()
                vim.api.nvim_buf_delete(orig_buf, { force = true })
                vim.api.nvim_buf_delete(mod_buf, { force = true })
            end)
        end)
    end)
end

--- Generate docstrings for code using AI prompts
---@param opts table Command options containing files in fargs
function M.docstrings(opts)
    run_prompt_command("docstrings", opts.fargs)
end

--- Add type hints to code using AI prompts
---@param opts table Command options containing files in fargs
function M.typehints(opts)
    run_prompt_command("typehints", opts.fargs)
end

--- Refactor code using AI prompts
---@param opts table Command options containing files in fargs
function M.refactor(opts)
    run_prompt_command("refactor", opts.fargs)
end

--- Fix code issues using AI prompts
---@param opts table Command options containing files in fargs
function M.fix(opts)
    run_prompt_command("fix", opts.fargs)
end

--- Generate unit tests using AI prompts
---@param opts table Command options containing files in fargs
function M.unittests(opts)
    run_prompt_command("unittests", opts.fargs)
end

return M
