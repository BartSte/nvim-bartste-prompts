local core = require("prompts._core")
local log = require("prompts._core.log")
local notifier = require("prompts.notifier")

local function abort(file)
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
        notifier.spinner.hide(job)
        core.job.delete(file)
    end
end

return abort
