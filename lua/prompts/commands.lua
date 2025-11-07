local core = require("prompts._core")
local opts = require("prompts._core.opts")
local log = require("prompts._core.log")

local M = {}

--- Run a command that will apply modifications to the current buffer
---@param command string The shell command to execute
---@param args? vim.api.keyset.create_user_command.command_args The command arguments passed in the user command
function M.edit(command, args)
    local file = vim.api.nvim_buf_get_name(0)
    log.info("User invoked %s on %s", tostring(command), file)
    core.run(command, args, "aider-code", core.on_exit.edit)
end

--- Run a command that generates output to stdout about the current buffer
---@param command string The shell command to execute
---@param args? vim.api.keyset.create_user_command.command_args The command arguments passed in the user command
---@return nil
function M.output(command, args)
    local file = vim.api.nvim_buf_get_name(0)
    log.info("User invoked %s (output) on %s", tostring(command), file)
    core.run(command, args, "aider-ask")
end

--- Run a command that asks a question and shows textual output
---@param command string Shell command (always "ask")
---@param args? vim.api.keyset.create_user_command.command_args
function M.ask(command, args)
    local seed = args and args.args or ""
    local sanitized_seed = (seed or ""):gsub("%s+", " ")
    log.info("User ask command seed='%s'", sanitized_seed)
    local question = vim.fn.input("Ask question: ", seed)
    question = vim.trim(question or "")
    if question == "" then
        log.debug("Ask command cancelled (empty input)")
        vim.notify("Ask command cancelled", vim.log.levels.WARN)
        return
    end

    args = vim.deepcopy(args or {})
    args.args = question
    if args.range == nil then
        args.range = 0
    end
    log.debug("Dispatching ask command with range=%s", tostring(args.range))
    return M.output(command, args)
end

function M.commit()
    log.info("User invoked commit command")
    local diff = vim.fn.system({ "git", "diff", "--cached" })
    if vim.v.shell_error ~= 0 then
        local message = "Failed to collect git diff:\n" .. diff
        log.error(message)
        vim.notify(message, vim.log.levels.ERROR)
        return
    end

    local trimmed = vim.trim(diff)
    if trimmed == "" then
        log.info("No staged changes to commit")
        vim.notify("No staged changes to commit", vim.log.levels.INFO)
        return
    end

    log.info("Dispatching commit command with staged diff length=%d", #trimmed)
    core.run("commit", {
        range = 0,
        line1 = 0,
        line2 = 0,
        args = diff,
    }, "aider-commit")
end

--- Restore the file to its previous state before command execution
---@param file? string Optional path to file to restore (default: current buffer)
---@return nil
function M.undo(file)
    if type(file) ~= "string" then
        file = vim.api.nvim_buf_get_name(0)
    end
    log.info("Attempting undo for %s", file)
    local backup_dir = opts.get().backup_dir
    local abs = vim.fn.fnamemodify(file, ":p")
    local hash = vim.fn.sha256(abs):sub(1, 8)
    local basename = vim.fn.fnamemodify(file, ":t")
    local tmp = string.format("%s/%s-%s", backup_dir, hash, basename)

    if vim.fn.filereadable(tmp) == 0 then
        log.warn("No previous version to restore for %s", file)
        return vim.notify("No previous version to restore", vim.log.levels.ERROR)
    end

    vim.fn.writefile(vim.fn.readfile(tmp), file)
    vim.cmd("e! " .. file)
    local message = string.format("Restored %s from backup", basename)
    log.info(message)
    vim.notify(message, vim.log.levels.INFO)
end

--- Check if there's an active job for the given file
---@param file? string Optional path to check (default: current buffer)
---@return boolean
function M.is_running(file)
    if type(file) ~= "string" then
        file = vim.api.nvim_buf_get_name(0)
    end
    local running = core.job.get(file) ~= nil
    log.debug("Checked running job for %s -> %s", file, tostring(running))
    return running
end

--- Abort any running job for the given file
---@param file? string Optional path to check (default: current buffer)
---@return nil
function M.abort(file)
    if type(file) ~= "string" then
        file = vim.api.nvim_buf_get_name(0)
    end
    log.info("Abort requested for %s", file)
    local job = core.job.get(file)
    if not job or not job.process then
        log.warn("No job to abort for %s", file)
        vim.notify("No job to abort for this file", vim.log.levels.ERROR)
        return
    end

    if job.process then
        log.info("Terminating job for %s", file)
        job.process:kill()
        require("prompts.notifier").spinner.hide(job)
        core.job.delete(file)
    end
end

--- Show output buffer for a job
---@param file? string Optional path to file (default: current buffer)
function M.show_output(file)
    if not file or file == "" then
        file = vim.api.nvim_buf_get_name(0)
    end
    log.info("Showing output for %s", file)

    local job = core.job.get(file)
    local buffer

    if job and job.buffer and vim.api.nvim_buf_is_valid(job.buffer) then
        buffer = job.buffer
        log.debug("Using existing job output buffer %s for %s", buffer, file)
    else
        buffer = core.outputbuf.new(file)
        local has_history = core.history.render(file, buffer)
        if not has_history then
            local message = "No output available for file: " .. file
            log.info(message)
            vim.notify(message, vim.log.levels.INFO)
            return
        end
        log.debug("Rendered history into output buffer %s for %s", buffer, file)
    end

    local cmd = "vert new | wincmd L | b %s | wincmd w"
    vim.cmd(string.format(cmd, buffer))
end

return M
