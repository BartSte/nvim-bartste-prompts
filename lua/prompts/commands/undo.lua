local opts = require("prompts._core.opts")
local log = require("prompts._core.log")

local function undo(file)
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

return undo
