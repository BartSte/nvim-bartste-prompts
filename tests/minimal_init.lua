local function git_root()
  local cwd = vim.loop.cwd()
  local out = vim.fn.systemlist({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })
  if vim.v.shell_error ~= 0 or #out == 0 then
    vim.notify("Not in a git repository. Assuming current directory as root.", vim.log.levels.WARN)
    return '.'
  end
  return out[1]
end

local function update_runtimepath()
  local root = git_root()
  vim.opt.rtp:append(root)

  local plenary_path = root .. "/plenary.nvim"
  if vim.fn.isdirectory(plenary_path) == 0 then
    vim.notify("plenary.nvim not found, running git submodule.", vim.log.levels.WARN)
    vim.fn.system({ "git", "submodule", "update", "--init", "--recursive" })
  end
  vim.opt.rtp:append(plenary_path)

  vim.notify("rtp updated with: " .. root .. " and " .. plenary_path, vim.log.levels.INFO)
end

vim.notify("Start loading minimal_init.lua", vim.log.levels.INFO)
update_runtimepath()
require("plenary.test_harness")
vim.notify("Finished loading minimal_init.lua", vim.log.levels.INFO)
