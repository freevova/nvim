-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-------------------- MAPPINGS ------------------------------
map("i", "jj", "<ESC>", { noremap = true }) -- alias for exit

map("n", "<C-J>", "<C-W><C-J>", {noremap = true})
map("n", "<C-K>", "<C-W><C-K>", {noremap = true})
map("n", "<C-L>", "<C-W><C-L>", {noremap = true})
map("n", "<C-H>", "<C-W><C-H>", {noremap = true})
map("t", "<C-H>", "<C-\\><C-n><C-W>h", {noremap = true})
map("t", "<C-J>", "<C-\\><C-n><C-W>j", {noremap = true})
map("t", "<C-K>", "<C-\\><C-n><C-W>k", {noremap = true})
map("t", "<C-L>", "<C-\\><C-n><C-W>l", {noremap = true})
map("n", "|", ":vsplit<CR>", { noremap = true })
map("n", "_", ":split<CR>", { noremap = true })

-- turn search off
map("n", "<leader><space>", ":noh<CR>", { noremap = true, desc = "Clear search highlighting" })

-- replace default search with search by regex
vim.api.nvim_set_keymap("n", "/", "/\\v", { noremap = true })
vim.api.nvim_set_keymap("v", "/", "/\\v", { noremap = true })

-- Cycle through relativenumber + number, number (only), and no numbering.
local function cycle_numbering()
  if vim.wo.relativenumber then
    vim.wo.relativenumber = false
    vim.wo.number = true
  elseif vim.wo.number then
    vim.wo.number = false
  else
    vim.wo.relativenumber = true
    vim.wo.number = true
  end
end

vim.keymap.set("n", "<leader>r", cycle_numbering, { desc = "Cycle line numbering" })

