return {
  -- search/replace in multiple files
  {
    "MagicDuck/grug-far.nvim",
    opts = { headerMaxWidth = 80 },
    cmd = { "GrugFar", "GrugFarWithin" },
    keys = {
      {
        "<leader>sr",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.open({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            },
          })
        end,
        mode = { "n", "x" },
        desc = "Search and Replace",
      },
    },
  },

  -- Flash enhances the built-in search functionality by showing labels
  -- at the end of each match, letting you quickly jump to a specific
  -- location.
  {
    "folke/flash.nvim",
    vscode = true,
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "g/", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      -- Simulate nvim-treesitter incremental selection
      { "<c-space>", mode = { "n", "o", "x" },
        function()
          require("flash").treesitter({
            actions = {
              ["<c-space>"] = "next",
              ["<BS>"] = "prev"
            }
          }) 
        end, desc = "Treesitter Incremental Selection" },
    },
  },

  -- for manipulation with parentheses, brackets, quotes
  {
    "tpope/vim-surround",
    init = function()
      -- defaults (ys/cs/ds) start with builtin operators, so which-key cannot
      -- show them; everything lives under <leader>c instead
      vim.g.surround_no_mappings = 1
    end,
    keys = {
      { "<leader>ca", "<Plug>Ysurround", desc = "Add surrounding" },
      { "<leader>cA", "<Plug>YSurround", desc = "Add surrounding, on new lines" },
      { "<leader>cl", "<Plug>Yssurround", desc = "Surround line" },
      { "<leader>cL", "<Plug>YSsurround", desc = "Surround line, on new lines" },
      { "<leader>cd", "<Plug>Dsurround", desc = "Delete surrounding" },
      { "<leader>cr", "<Plug>Csurround", desc = "Replace surrounding" },
      { "<leader>cR", "<Plug>CSurround", desc = "Replace surrounding, on new lines" },
      { "<leader>ca", "<Plug>VSurround", mode = "x", desc = "Surround selection" },
      { "<leader>cA", "<Plug>VgSurround", mode = "x", desc = "Surround selection, on new lines" },
      { "<C-g>s", "<Plug>Isurround", mode = "i", desc = "Add surrounding" },
      { "<C-g>S", "<Plug>ISurround", mode = "i", desc = "Add surrounding, on new lines" },
    },
  },

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

  -- autoclose parentheses
  {
    "windwp/nvim-autopairs",
    config = function()
      local npairs = require("nvim-autopairs")
      local Rule = require("nvim-autopairs.rule")

      npairs.setup({
        check_ts = true,
        ts_config = {
          -- the check only looks at the node under the cursor, so leaf types:
          -- quoted_content covers strings, heredocs, charlists and sigils
          elixir = { "quoted_content", "comment" },
        },
      })

      npairs.add_rules({
        -- plain `{` is suppressed inside strings by the rule above
        Rule("#{", "}", "elixir"),
      })
      -- `end` after Enter on a line ending with do, fn or fn ... ->
      npairs.add_rules(require("nvim-autopairs.rules.endwise-elixir"))
    end,
  },

  -- which-key helps you remember key bindings by showing a popup
  -- with the active keybindings of the command you started typing.
  -- { "folke/which-key.nvim", dependencies = { "echasnovski/mini.icons" } },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    dependencies = { "echasnovski/mini.icons" },
    opts_extend = { "spec" },
    opts = {
      preset = "helix",
      spec = {
        {
          mode = { "n", "x" },
          { "<leader>a", group = "ai" },
          { "<leader>c", group = "change" },
          { "<leader>g", group = "git" },
          { "<leader>gc", group = "conflict" },
          { "<leader>s", group = "search" },
          { "<leader>u", group = "ui" },
          { "<leader>x", group = "diagnostics/quickfix" },
          { "<leader>t", group = "test" },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "gl", group = "lsp" },
          { "z", group = "fold" },
          {
            "<leader>b",
            group = "buffer",
            expand = function()
              return require("which-key.extras").expand.buf()
            end,
          },
          {
            "<leader>w",
            group = "windows",
            proxy = "<c-w>",
            expand = function()
              return require("which-key.extras").expand.win()
            end,
          },
          -- better descriptions
          { "gx", desc = "Open with system app" },
        },
        {
          -- Neovim default, normal mode only
          mode = "n",
          { "gO", desc = "Document symbols" },
        },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Keymaps (which-key)",
      },
      {
        "<c-w><space>",
        function()
          require("which-key").show({ keys = "<c-w>", loop = true })
        end,
        desc = "Window Hydra Mode (which-key)",
      },
    },
  },

  -- better yank/paste
  {
    "gbprod/yanky.nvim",
    recommended = true,
    desc = "Better Yank/Paste",
    opts = {
      system_clipboard = {
        sync_with_ring = not vim.env.SSH_CONNECTION,
      },
      highlight = { timer = 150 },
    },
    keys = {
      {
        "<leader>sp",
        function()
          require("telescope").extensions.yank_history.yank_history()
        end,
        mode = { "n", "x" },
        desc = "Yank history",
      },
        -- stylua: ignore
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank Text" },
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put Text After Cursor" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Cursor" },
      { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put Text After Selection" },
      { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Selection" },
      { "[y", "<Plug>(YankyCycleForward)", desc = "Cycle Forward Through Yank History" },
      { "]y", "<Plug>(YankyCycleBackward)", desc = "Cycle Backward Through Yank History" },
      { "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put Indented After Cursor (Linewise)" },
      { "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put Indented Before Cursor (Linewise)" },
      { "]P", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put Indented After Cursor (Linewise)" },
      { "[P", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put Indented Before Cursor (Linewise)" },
      { ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and Indent Right" },
      { "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and Indent Left" },
      { ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put Before and Indent Right" },
      { "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put Before and Indent Left" },
      { "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put After Applying a Filter" },
      { "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put Before Applying a Filter" },
    },
  },

  -- This Vim script adds motions similar to w, b, e that navigate not by whole words but by CamelCase and
  -- underscore_notation boundaries within identifiers (e.g., stopping at each capitalized segment or
  -- underscore-delimited part). It also provides an inner "word" text object for selecting and operating on
  -- individual sub-parts of such identifiers.
  {
    "bkad/CamelCaseMotion",
    config = function()
      vim.api.nvim_set_keymap("", "w", "<Plug>CamelCaseMotion_w", {})
      vim.api.nvim_set_keymap("", "b", "<Plug>CamelCaseMotion_b", {})
      vim.api.nvim_set_keymap("", "e", "<Plug>CamelCaseMotion_e", {})
      vim.api.nvim_set_keymap("", "ge", "<Plug>CamelCaseMotion_ge", {})
    end,
  },

  -- plugin to place, toggle and display marks
  { "chentoast/marks.nvim", config = true },

  -- allows to navigate seamlessly between vim and tmux splits using a consistent set of hotkeys.
  {
    "christoomey/vim-tmux-navigator",
    event = "VeryLazy",
  },
}
