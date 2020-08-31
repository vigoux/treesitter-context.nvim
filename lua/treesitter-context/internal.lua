local api = vim.api
local locals = require'nvim-treesitter.locals'
local ts_utils = require'nvim-treesitter.ts_utils'

local M = {}
local preview_buf

function M.update(bufnr)
  if not preview_buf then return end

  local current_win = api.nvim_get_current_win()

  local current_node = ts_utils.get_node_at_cursor(current_win)

  local scopes = locals.get_scope_tree(current_node, bufnr)

  local text = {}

  for _, scope in ipairs(scopes) do
    if scope:parent() then
      local scope_first_line = ts_utils.get_node_text(scope, bufnr)[1]
      table.insert(text, 1, scope_first_line)
    end
  end

  api.nvim_buf_set_lines(preview_buf, 0, -1, false, text)

  return text
end

function M.setup(bufnr)
  vim.cmd[[pedit]]
  vim.cmd[[wincmd P]]
  local preview_win = api.nvim_get_current_win()
  vim.cmd[[wincmd p]]

  local tmp_buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_name(tmp_buf, "context")

  api.nvim_win_set_buf(preview_win, tmp_buf)

  preview_buf = tmp_buf
end

function M.attach(bufnr, lang)
  vim.cmd(string.format("augroup Treesitter_Context_%d", bufnr))
  vim.cmd(string.format([[autocmd CursorMoved <buffer=%d> lua require"treesitter-context.internal".update(%d)]], bufnr, bufnr))
  vim.cmd[[augroup END]]

  M.setup(bufnr)

  M.update(bufnr)
end

function M.detach(bufnr)
  vim.cmd(string.format("augroup! Treesitter_Context_%d", bufnr))
end

return M
