local M = {}

function M.run_prompt(command, files)
    local cmd = string.format("prompts %s %s", command, table.concat(files, " "))
    local handle = io.popen(cmd)
    if not handle then
        return nil, "Failed to run prompts command"
    end
    local result = handle:read("*a")
    handle:close()
    return result
end

function M.show_diff(original, modified)
    vim.cmd("tabnew")
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, original)
    
    vim.cmd("vnew")
    local diff_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(diff_buf, 0, -1, false, modified)
    
    vim.cmd("windo diffthis")
    return buf, diff_buf
end

function M.prompt_user_accept()
    local choice = vim.fn.input("Accept changes? (y/n): ")
    return choice:lower() == "y"
end

return M
