local M = {}

function M.new(file)
  local buf
  local bufname = M.get_name(file)
  if vim.fn.bufexists(bufname) ~= 0 then
    buf = M.get(file)
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, {})
  else
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, bufname)
  end

  -- Set buffer options using vim.bo
  local bo = vim.bo[buf]
  bo.buftype = 'nofile'
  bo.swapfile = false
  bo.filetype = 'prompts-output'
  bo.modifiable = true

  return buf
end

function M.get_name(file)
  local basename = vim.fn.fnamemodify(file, ":t")
  return string.format("prompts-output://%s", basename)
end

function M.get(file)
  local bufname = M.get_name(file)
  return vim.fn.bufnr(bufname)
end

function M.append(bufnr, lines)
  if not bufnr then
    return
  end
  if type(lines) == "string" then
    lines = vim.split(lines, "\n", { trimempty = false })
  end

  if type(lines) ~= "table" or #lines == 0 then
    return
  end

  if #lines == 0 then
    return
  end

  -- Schedule buffer updates in main event loop
  vim.schedule(function()
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    vim.api.nvim_buf_set_lines(bufnr, line_count, line_count, false, lines)
  end)
end

return M
