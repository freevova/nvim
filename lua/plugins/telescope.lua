return {
  --  highly extendable fuzzy finder over lists
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    -- these live in the which-key "search" group (<leader>s, see plugins/editor.lua)
    keys = {
      {
        "<leader>sf",
        function()
          require("telescope.builtin").find_files()
        end,
        desc = "Find files",
      },
      {
        "<leader>sg",
        function()
          require("telescope.builtin").live_grep()
        end,
        desc = "Live grep",
      },
      {
        "<leader>sb",
        function()
          require("telescope.builtin").buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>sh",
        function()
          require("telescope.builtin").help_tags()
        end,
        desc = "Help tags",
      },
      {
        "<leader>ss",
        function()
          require("telescope.builtin").lsp_document_symbols()
        end,
        desc = "Document symbols",
      },
      {
        "<leader>sS",
        function()
          require("telescope.builtin").lsp_dynamic_workspace_symbols()
        end,
        desc = "Workspace symbols",
      },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        pickers = {
          buffers = {
            mappings = {
              i = {
                ["<c-d>"] = actions.delete_buffer + actions.move_to_top,
              },
            },
          },
        },
        defaults = {
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
            },
          },
          sorting_strategy = "ascending",
          --- other configs
          mappings = {
            i = {
              ["<esc>"] = actions.close,
              ["<C-p>"] = false,
              ["<C-n>"] = false,
              ["<C-j>"] = {
                actions.move_selection_next,
                type = "action",
                opts = { nowait = true, silent = true },
              },
              ["<C-k>"] = {
                actions.move_selection_previous,
                type = "action",
                opts = { nowait = true, silent = true },
              },
            },
          },
        },
      })

      telescope.load_extension("fzf")
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- fzf sorter compiled with make; loaded together with telescope
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
  },
}
