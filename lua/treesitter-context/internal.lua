local api = vim.api
local locals = require'nvim-treesitter.locals'
local ts_utils = require'nvim-treesitter.ts_utils'

local M = {}
local preview_buf
local preview_win

function M.update(bufnr)
  if not (preview_buf and api.nvim_win_is_valid(preview_win)) then return end

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
  local win_height
  if #text == 0 then
    win_height = 1
  else
    win_height = #text
  end

  api.nvim_win_set_config(preview_win, {height = win_height})

  return text
end

function M.setup(bufnr)
  preview_buf = api.nvim_create_buf(false, true)
  local columns = api.nvim_get_option('columns')

  preview_win = api.nvim_open_win(preview_buf, false, {
    relative = "editor",
    anchor = "NE",
    width = 60,
    height = 1,
    row = 0,
    col = columns,
    focusable = false,
    style = "minimal"
  })
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
