local M = {}

local LEVELS = { ERROR = 40, WARN = 30, INFO = 20, DEBUG = 10 }
local NAMES = {}
for name, value in pairs(LEVELS) do
  NAMES[value] = name
end

local state = {
  level_name = "INFO",
  level = LEVELS.INFO,
  file = nil,
}

local function resolve_level(level)
  if type(level) == "number" then
    return NAMES[level] or "INFO"
  end
  if type(level) == "string" then
    level = level:upper()
    if LEVELS[level] then
      return level
    end
  end
  return "INFO"
end

local function should_log(level_name)
  local numeric = LEVELS[level_name]
  return numeric ~= nil and numeric >= state.level and state.file ~= nil
end

function M.setup(config)
  config = config or {}
  local level_name = resolve_level(config.loglevel or config.log_level or state.level_name)
  state.level_name = level_name
  state.level = LEVELS[level_name]

  local target = config.log_file or (vim.fn.stdpath("cache") .. "/prompts/prompts.log")
  target = vim.fn.expand(target)
  local dir = vim.fn.fnamemodify(target, ":h")
  if dir and dir ~= "" then
    vim.fn.mkdir(dir, "p")
  end
  state.file = target
  M.info("logging initialised (level=%s, file=%s)", level_name, target)
end

function M.log(level_name, message, ...)
  level_name = resolve_level(level_name)
  if not should_log(level_name) then
    return
  end

  local ok, formatted = pcall(string.format, message, ...)
  if not ok then
    formatted = message
  end
  local line = string.format("%s [%s] %s", os.date("%Y-%m-%d %H:%M:%S"), level_name, formatted)
  pcall(vim.fn.writefile, { line }, state.file, "a")
end

function M.debug(message, ...)
  M.log("DEBUG", message, ...)
end

function M.info(message, ...)
  M.log("INFO", message, ...)
end

function M.warn(message, ...)
  M.log("WARN", message, ...)
end

function M.error(message, ...)
  M.log("ERROR", message, ...)
end

return M
