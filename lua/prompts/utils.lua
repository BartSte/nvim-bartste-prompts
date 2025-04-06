local M = {}

function M.run_prompt(command, files, callback)
    local cmd = string.format("prompts %s %s", command, table.concat(files, " "))
    local stdout = vim.loop.new_pipe(false)
    local stderr = vim.loop.new_pipe(false)
    
    local handle, pid
    handle, pid = vim.loop.spawn("prompts", {
        args = {command, unpack(files)},
        stdio = {nil, stdout, stderr},
    }, function(code, signal)
        stdout:read_stop()
        stderr:read_stop()
        stdout:close()
        stderr:close()
        handle:close()
        
        if code ~= 0 then
            callback(nil, "Command failed with code "..code)
        end
    end)
    
    if not handle then
        return callback(nil, "Failed to spawn process")
    end
    
    local result = {}
    stdout:read_start(function(err, data)
        if err then
            return callback(nil, "Read error: "..err)
        end
        if data then
            table.insert(result, data)
        end
    end)
    
    stderr:read_start(function(err, data)
        if err or data then
            return callback(nil, "Error: "..(data or err))
        end
    end)
    
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
