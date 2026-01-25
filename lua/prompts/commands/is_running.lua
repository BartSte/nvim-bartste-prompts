local core = require("prompts._core")
local log = require("prompts._core.log")

local function is_running(file)
    if type(file) ~= "string" then
        file = vim.api.nvim_buf_get_name(0)
    end
    local running = core.registry.get(file) ~= nil
    log.debug("Checked running job for %s -> %s", file, tostring(running))
    return running
end

return is_running
