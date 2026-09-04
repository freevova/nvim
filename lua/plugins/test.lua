return {
  -- send commands to tmux pane
  {
    "jgdavey/tslime.vim",
    lazy = true,
    init = function()
      vim.g.tslime_always_current_session = 1 -- run in current session
    end,
  },

  -- test runner
  {
    "vim-test/vim-test",
    dependencies = { "jgdavey/tslime.vim" },
    cmd = { "TestNearest", "TestFile", "TestLast", "TestSuite" },
    keys = {
      { "<leader>tn", "<cmd>TestNearest<cr>", desc = "Test nearest" },
      { "<leader>tf", "<cmd>TestFile<cr>", desc = "Test file" },
      { "<leader>tl", "<cmd>TestLast<cr>", desc = "Test last" },
    },
    init = function()
      vim.g["test#strategy"] = "tslime"
    end,
  },
}
