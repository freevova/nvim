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

      vim.keymap.set("n", "<leader>tn", ":TestNearest<CR>", { desc = "Test nearest" })
      vim.keymap.set("n", "<leader>tf", ":TestFile<CR>", { desc = "Test file" })
      vim.keymap.set("n", "<leader>tl", ":TestLast<CR>", { desc = "Test last" })
    end,
  },
}
