local core = require("prompts._core")
local log = require("prompts._core.log")

local function output(command, args)
    local file = vim.api.nvim_buf_get_name(0)
    log.info("User invoked %s (output) on %s", tostring(command), file)
    core.run(command, args, "aider-ask")
end

return output
