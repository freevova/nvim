return function()
  vim.cmd("let test#strategy = 'tslime'")

  vim.api.nvim_set_keymap("n", "<space>tn", ":TestNearest<CR>", { noremap = false })
  vim.api.nvim_set_keymap("n", "<space>tf", ":TestFile<CR>", { noremap = false })
  vim.api.nvim_set_keymap("n", "<space>tl", ":TestLast<CR>", { noremap = false })
end
