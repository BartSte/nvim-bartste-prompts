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

    -- Create progress indicator
    local progress_buf = vim.api.nvim_create_buf(false, true)
    local width = 30
    local height = 3
    local win = vim.api.nvim_open_win(progress_buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        col = (vim.o.columns - width) / 2,
        row = (vim.o.lines - height) / 2 - 1,  -- Adjust for status line
        style = 'minimal',
        border = 'rounded'
    })
    vim.api.nvim_buf_set_lines(progress_buf, 0, -1, false, {' Processing... ⌛ ', 'Please wait'})
    vim.api.nvim_win_set_option(win, 'winhl', 'Normal:FloatBorder')

    utils.run_prompt(command, files, function(result, err)
        -- Clean up progress window first
        vim.schedule(function()
            pcall(vim.api.nvim_win_close, win, {force = true})
            pcall(vim.api.nvim_buf_delete, progress_buf, {force = true})
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
                vim.cmd("Gvdiffsplit!")
                vim.notify("Changes applied", vim.log.levels.INFO)
            else
                vim.notify("Changes discarded", vim.log.levels.WARN)
            end

            vim.api.nvim_buf_delete(orig_buf, { force = true })
            vim.api.nvim_buf_delete(mod_buf, { force = true })
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
