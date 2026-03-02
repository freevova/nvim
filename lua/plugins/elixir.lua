return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost", "BufReadPost", "InsertLeave" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        fish = { "fish" },
        elixir = { "credo" },
      }

      lint.linters.credo = vim.tbl_deep_extend("force", lint.linters.credo or {}, {
        condition = function(ctx)
          return vim.fs.find({ ".credo.exs" }, { path = ctx.filename, upward = true })[1]
        end,
      })

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
