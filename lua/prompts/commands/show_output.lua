local core = require("prompts._core")
local log = require("prompts._core.log")

local function show_output(file)
    if not file or file == "" then
        file = vim.api.nvim_buf_get_name(0)
    end
    log.info("Showing output for %s", file)

    local job = core.registry.get(file)
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

return show_output
