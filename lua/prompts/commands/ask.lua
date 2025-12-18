local log = require("prompts._core.log")
local output = require("prompts.commands.output")

local function ask(command, args)
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
    return output(command, args)
end

return ask
