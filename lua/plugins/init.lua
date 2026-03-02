return {
  { "folke/lazy.nvim", version = "*" },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = { 
      image = { enabled = true }
    },
    config = function(_, opts)
      local notify = vim.notify
      require("snacks").setup(opts)
    end,
  },
}
