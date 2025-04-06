local M = {}
local utils = require("bartste-prompts.utils")

local function run_prompt_command(command, files)
    if #files == 0 then
        files = { vim.api.nvim_buf_get_name(0) }
    end
    
    local original = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    
    vim.notify("Running prompt command...", vim.log.levels.INFO)
    
    utils.run_prompt(command, files, function(result, err)
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
                vim.notify("Changes applied", vim.log.levels.INFO)
            else
                vim.notify("Changes discarded", vim.log.levels.WARN)
            end
            
            vim.api.nvim_buf_delete(orig_buf, { force = true })
            vim.api.nvim_buf_delete(mod_buf, { force = true })
        end)
    end)
end

function M.docstrings(opts)
    run_prompt_command("docstrings", opts.fargs)
end

function M.typehints(opts)
    run_prompt_command("typehints", opts.fargs)
end

function M.refactor(opts)
    run_prompt_command("refactor", opts.fargs)
end

function M.fix(opts)
    run_prompt_command("fix", opts.fargs)
end

function M.unittests(opts)
    run_prompt_command("unittests", opts.fargs)
end

return M
