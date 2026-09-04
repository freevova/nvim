return {
  --  highly extendable fuzzy finder over lists
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      local map = function(mode, lhs, rhs)
        local opts = { noremap = true, silent = true }
        vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
      end

      function project_files()
        local opts = {
          layout_config = {
            prompt_position = "top",
          },
          sorting_strategy = "ascending",
        }
        local ok = pcall(require("telescope.builtin").git_files, opts)
        if not ok then
          require("telescope.builtin").find_files(opts)
        end
      end

      local builtin = require("telescope.builtin")
      -- these live in the which-key "search" group (<leader>s, see plugins/editor.lua)
      vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Help tags" })
      vim.keymap.set("n", "<leader>ss", builtin.lsp_document_symbols, { desc = "Document symbols" })

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
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  -- a plugin for fzf algorithm
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },
}
