-- _G.NvimTreeOpenWith = function()
--   local lib = require("nvim-tree.lib")
--   local utils = require("nvim-tree.utils")
--   local node = lib.get_node_at_cursor()
--   if node then
--     local command = vim.fn.input("Open '" .. utils.path_basename(node.absolute_path) .. "' with: ", "xdg-open")
--     vim.fn.jobstart(command .. " '" .. node.absolute_path .. "' 2>/dev/null&", { detach = true })
--   end
-- end

local function on_attach(bufnr)
  local api = require("nvim-tree.api")

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end
  -- default mappings
  api.config.mappings.default_on_attach(bufnr)

  -- custom mappings
  vim.keymap.set("n", "|", api.node.open.vertical, opts("Open: Vertical Split"))
  vim.keymap.set("n", "_", api.node.open.horizontal, opts("Open: Horizontal Split"))
  vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))

  vim.api.nvim_set_keymap("", "<C-p>", ":NvimTreeToggle<CR>", { noremap = true })
  vim.api.nvim_set_keymap("", "<C-F>", ":NvimTreeFindFile<CR>", { noremap = true })
end

return function()
  require("nvim-tree").setup({
    on_attach = on_attach,
    view = {
      width = 50,
    },
    renderer = {
      special_files = {}, -- don't highlight readme files
      indent_markers = {
        enable = true,
      },
    },
  })
end
