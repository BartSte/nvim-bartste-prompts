local notifier = require("prompts.notifier")
local outputbuf = require("prompts._core.outputbuf")

--- Create a backup copy of the current file
---@param job prompts.Job The job object
---@param file string The path of the file to back up
local function make_backup(job, file)
    local file_content = vim.fn.readfile(file)
    vim.fn.writefile(file_content, job.tmp)
end

--- Build command table for job execution
---@param job prompts.Job The job object containing command details
---@return string[] The command table for the job
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

--- Create a writer function for job output
---@param job prompts.Job The job object
---@return fun(process: any, data: string) The writer function
local function make_writer(job)
    return function(_, data)
        outputbuf.append(job.buffer, data)
    end
end

--- Execute a prompts job by preparing the environment and starting the process
--- Reads the current buffer, writes it to a temporary copy, and invokes the prompts CLI
---@param command string The command to dispatch to the prompts CLI
---@param args string[] List of arguments to pass to the job
---@param action string The `prompts <command> --action <action>` value
---@param on_exit fun(job: prompts.Job)? Optional callback invoked upon job completion
---@return nil
return function(command, args, action, on_exit)
    local core = require("prompts._core")
    local file = vim.api.nvim_buf_get_name(0)
    local filetype = vim.bo.filetype
    local job = core.job.new(command, file, filetype, action, args)
    if not job then
        vim.notify("A job is already running for file " .. file, vim.log.levels.ERROR)
        return
    end

    make_backup(job, file)
    local cmd = make_cmd(job)
    local opts = {
        stdout = make_writer(job),
        stderr = make_writer(job),
        text = true
    }
    on_exit = on_exit or core.on_exit.default
    job.process = vim.system(cmd, opts, on_exit(job))
    notifier.spinner.show(job)
end
