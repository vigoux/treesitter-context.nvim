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
  local displayed = {} -- Already displayed lines
  local toprow = vim.fn.line("w0") - 1
  local max_width = -math.huge

  for _, scope in ipairs(scopes) do
    local start_row, _, _ = scope:start()

    -- FIXME(vigoux): this is not actually what we mean, some weird things can happen
    -- For example :
    -- if (test // Only this will be shown
    --  || test) {
    -- }

    local line = api.nvim_buf_get_lines(bufnr, start_row, start_row+1, false)[1]

    if scope:parent() and not displayed[start_row] and toprow > start_row then
      table.insert(text, 1, line)
      displayed[start_row] = 1

      max_width = math.max(max_width, #line)
    end
  end

  api.nvim_buf_set_lines(preview_buf, 0, -1, false, text)

  api.nvim_win_set_config(preview_win, {
    height = math.max(1, #text),
    width = math.max(max_width, 60)
  })

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
    col = 9000, -- To always have it top right
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
