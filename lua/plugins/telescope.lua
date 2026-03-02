return {
  --  highly extendable fuzzy finder over lists
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      -- local lga_actions = require("telescope-live-grep-args.actions")

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

      -- map("n", "<leader>ff", "<CMD>lua project_files()<CR>")
      -- map("n", "<leader>ff", ":Telescope find_files prompt_position=top --no_ignore<CR>")
      -- map("n", "<leader>fF", ":lua require('telescope.builtin').find_files({prompt_position=top, no_ignore = true})<CR>")
      -- map("n", "<leader>fg", ":Telescope live_grep_args theme=get_ivy prompt_prefix=🔍<CR>")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
      -- vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
      vim.keymap.set(
        "n",
        "<leader>fg",
        ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
        { desc = "Telescope live grep" }
      )
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
      vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Telescope lsp symbols" })

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
        extensions = {
          live_grep_args = {
            auto_quoting = true, -- enable/disable auto-quoting
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

      telescope.load_extension("live_grep_args")
      telescope.load_extension("search_dir_picker")
    end,
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-live-grep-args.nvim",
      "smilovanovic/telescope-search-dir-picker.nvim",
    },
  },

  -- search tool that recursively searches the current directory for a regex pattern
  "jremmen/vim-ripgrep",

  -- a plugin for fzf algorithm
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },
}
