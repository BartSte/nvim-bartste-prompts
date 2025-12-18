local core = require("prompts._core")
local notifier = require("prompts.notifier").spinner
local log = require("prompts._core.log")

local function commit()
  log.info("User invoked commit command")
  local diff = core.git.diff("--staged")
  if diff == "" then
    log.info("No staged changes to commit")
    vim.notify("No staged changes to commit", vim.log.levels.INFO)
    return
  end

  log.info("Dispatching commit command with staged diff length=%d", #diff)
  local args = { range = 0, line1 = 0, line2 = 0, args = diff }

  local on_exit = function(job)
    local default = core.on_exit.default(job)
    return vim.schedule_wrap(function(obj)
      default(obj)
    end)
  end
  core.run("commit", args, "aider-ask", on_exit)
end

return commit
