local queries = require "nvim-treesitter.query"

local M = {}

function M.init()
  require "nvim-treesitter".define_modules {
    context = {
      module_path = "treesitter-context.internal",
      enabled = false,
      -- We use the locals query for this plugin
      is_supported = queries.has_locals
    }
  }
end

return M
