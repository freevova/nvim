return {
  -- for manipulation with parentheses, brackets, quotes
  "tpope/vim-surround",
  -- ability to edit with multiple cursors
  "mg979/vim-visual-multi",
  -- switch between opposite terms
  {
    "AndrewRadev/switch.vim",
    init = function()
      vim.g.switch_mapping = "-"
      vim.g.switch_custom_definitions = { { "assert", "refute" }, { "and", "or" }, { "required", "optional" } }
    end,
  },
  {
    "stevearc/conform.nvim",
    keys = {
      {
        "===",
        "<cmd>Format<CR>",
        mode = "n",
        desc = "Format buffer",
      },
    },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          css = { "oxfmt" },
          html = { "oxfmt" },
          graphql = { "typos", "oxfmt" },
          typescript = { "typos", "oxfmt" },
          typescriptreact = { "typos", "oxfmt" },
          javascript = { "typos", "oxfmt" },
          elixir = { "typos", "mix" },
          sql = { "pg_format" },
          json = { "oxfmt" },
          python = { "ruff_format" },
          ["_"] = { "trim_whitespace", "trim_newlines" },
        },
        formatters = {
          stylua = {
            prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
          },
          mix = {
            cwd = require("conform.util").root_file({ ".formatter.exs", "mix.exs" }),
            require_cwd = true,
          },
        },
      })
      vim.api.nvim_create_user_command("Format", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end
        require("conform").format({ async = true, lsp_format = "fallback", range = range })
      end, { range = true })
    end,
  },
}
