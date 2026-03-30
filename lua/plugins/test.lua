return {
  -- send commands to tmux pane
  {
    "jgdavey/tslime.vim",
    init = function()
      vim.g.tslime_always_current_session = 1 -- run in current session
    end,
  },

  -- test runner
  {
    "vim-test/vim-test",
    dependencies = { "jgdavey/tslime.vim" },
    config = function()
      vim.cmd("let test#strategy = 'tslime'")

      vim.api.nvim_set_keymap("n", "<space>tn", ":TestNearest<CR>", { noremap = false })
      vim.api.nvim_set_keymap("n", "<space>tf", ":TestFile<CR>", { noremap = false })
      vim.api.nvim_set_keymap("n", "<space>tl", ":TestLast<CR>", { noremap = false })
    end,
  },
}
