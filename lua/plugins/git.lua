return {
  -- plugin for git
  { "tpope/vim-fugitive", dependencies = { "shumphrey/fugitive-gitlab.vim" } },

  -- shows a git diff in the sign column
  {
    "lewis6991/gitsigns.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      current_line_blame = true, -- toggle with <leader>ub
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
        virt_text_priority = 100,
      },
      current_line_blame_formatter = "<author>, <author_time:%x> - <summary>",
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, silent = true, desc = desc })
        end

        -- Navigation on ]h/[h: ]c/[c belong to treesitter-textobjects class motions
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end, "Next hunk")

        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end, "Prev hunk")

        -- Actions
        map("n", "<leader>gs", gitsigns.stage_hunk, "Stage hunk")
        map("n", "<leader>gr", gitsigns.reset_hunk, "Reset hunk")

        map("v", "<leader>gs", function()
          gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage hunk")

        map("v", "<leader>gr", function()
          gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset hunk")

        map("n", "<leader>gS", gitsigns.stage_buffer, "Stage buffer")
        map("n", "<leader>gR", gitsigns.reset_buffer, "Reset buffer")
        map("n", "<leader>gp", gitsigns.preview_hunk, "Preview hunk")
        map("n", "<leader>gi", gitsigns.preview_hunk_inline, "Preview hunk inline")

        map("n", "<leader>gb", function()
          gitsigns.blame_line({ full = true })
        end, "Blame line")

        map("n", "<leader>gd", gitsigns.diffthis, "Diff this")

        map("n", "<leader>gD", function()
          gitsigns.diffthis("~")
        end, "Diff this ~")

        map("n", "<leader>gq", gitsigns.setqflist, "Hunks to quickfix")

        map("n", "<leader>gQ", function()
          gitsigns.setqflist("all")
        end, "All hunks to quickfix")

        -- Toggles
        map("n", "<leader>ub", gitsigns.toggle_current_line_blame, "Toggle line blame")
        map("n", "<leader>uw", gitsigns.toggle_word_diff, "Toggle word diff")

        -- Text object
        map({ "o", "x" }, "ih", gitsigns.select_hunk, "Select hunk")
      end,
    },
  },

  -- a plugin to visualise and resolve conflicts in neovim
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    -- conflict detection runs on buffer read, so the plugin cannot be lazy
    lazy = false,
    opts = {
      -- defaults co/ct/cb/c0 shadow builtin ct{char} and cb in conflicted buffers
      default_mappings = false,
    },
    keys = {
      { "<leader>gco", "<Plug>(git-conflict-ours)", mode = { "n", "x" }, desc = "Choose ours" },
      { "<leader>gct", "<Plug>(git-conflict-theirs)", mode = { "n", "x" }, desc = "Choose theirs" },
      { "<leader>gcb", "<Plug>(git-conflict-both)", mode = { "n", "x" }, desc = "Choose both" },
      { "<leader>gcn", "<Plug>(git-conflict-none)", mode = { "n", "x" }, desc = "Choose none" },
      { "<leader>gcB", "<cmd>GitConflictChooseBase<cr>", desc = "Choose base" },
      { "<leader>gcl", "<cmd>GitConflictListQf<cr>", desc = "Conflicts to quickfix" },
      { "]x", "<Plug>(git-conflict-next-conflict)", desc = "Next conflict" },
      { "[x", "<Plug>(git-conflict-prev-conflict)", desc = "Prev conflict" },
    },
  },
}
