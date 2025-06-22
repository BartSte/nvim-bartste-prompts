--- Build command table for job execution.
---@param job prompts.Job The job object containing command details.
---@return string[] The command table for the job.
local function make_cmd(job)
    local core = require("prompts._core")
    return {
        "prompts", job.command,
        "--files", job.file,
        "--filetype", job.filetype,
        "--loglevel", core.opts.get().loglevel,
        "--user", job.userprompt,
        "--action", job.action
    }
end

--- Create output buffer for a job.
---@param file string Source file path.
---@return integer bufnr New buffer number.
local function create_output_buffer(file)
    local buf
    local basename = vim.fn.fnamemodify(file, ":t")
    local bufname = string.format("prompts-output://%s", basename)
    if vim.fn.bufexists(bufname) ~= 0 then
        buf = vim.fn.bufnr(bufname)
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, {})
    else
        buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(buf, bufname)
    end

    -- Set buffer options using vim.bo
    local bo = vim.bo[buf]
    bo.buftype = 'nofile'
    bo.swapfile = false
    bo.filetype = 'prompts-output'
    bo.modifiable = true

    return buf
end

--- Execute a prompts job by preparing the environment and starting the process.
--- Reads the current buffer, writes it to a temporary copy, and invokes the prompts CLI.
---@param command string The command to dispatch to the prompts CLI.
---@param args string[] List of arguments to pass to the job.
---@param action string The `prompts <command> --action <action>` value.
---@param on_exit fun(job: prompts.Job)? Optional callback invoked upon job completion.
---@return nil
return function(command, args, action, on_exit)
    local core = require("prompts._core")
    local notifier = require("prompts.notifier")
    local helpers = require("prompts._core.helpers")
    local file = vim.api.nvim_buf_get_name(0)
    local filetype = vim.bo.filetype

    local job = core.job.new(command, file, filetype, action, args)

    if job then
        local file_content = vim.fn.readfile(file)
        vim.fn.writefile(file_content, job.tmp)

        -- Create output buffer
        job.buffer = create_output_buffer(file)

        local cmd = make_cmd(job)
        on_exit = on_exit or core.on_exit.default
        job.process = vim.system(
            cmd,
            {
                stdout = function(_, data)
                    helpers.append_to_buffer(job.buffer, data)
                end,
                stderr = function(_, data)
                    helpers.append_to_buffer(job.buffer, data)
                end,
                text = true
            },
            on_exit(job)
        )
        notifier.spinner.show(job)
    else
        vim.notify("A job is already running for file " .. file, vim.log.levels.ERROR)
    end
end
