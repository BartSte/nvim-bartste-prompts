---@class prompts.GlobalOptions
---@field update fun(table)
---@field get fun() : table
local M = {}

---@class prompts.Opts
---@field notify boolean? Whether to show notifications
---@field loglevel string? The log level
---@field timeout_seconds integer? The default timeout in seconds
---@field backup_dir string? Directory path where backups are stored
local opts = {
  notify = false,
  loglevel = "WARNING",
  timeout_seconds = 1200,
  backup_dir = vim.fn.stdpath("cache") .. "/prompts_backup"
}

--- Update configuration options with a deep merge
---@param new prompts.Opts Table of new options to merge into current configuration
function M.update(new)
  opts = vim.tbl_deep_extend("force", opts, new)
end

--- Retrieve current configuration options
---@return prompts.Opts Table containing current configuration settings
function M.get()
  return opts
end

return M
