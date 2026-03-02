return {
  {
    "EdenEast/nightfox.nvim",
    config = function()
      -- most of the colors are from this colorscheme https://github.com/morhetz/gruvbox
      local palettes = {
        nightfox = {
          red = "#FB4934",
          yellow = "#FABD2F",
          purple = "#D3869b",
          green = "#B8BB26",
          orange = "#FE8019",
          -- blue = "#639EE4",
          blue = "#83A598", -- changed to match Gruvbox
          magenta = "#B888E2",
          -- cyan = "#4BB1A7",
          cyan = "#8EC07C", -- changed to match Gruvbox
          white = "#EBDBB2", -- Gruvbox fg
          pink = "#D65D0E", -- optional: used in light cases
          comment = "#928374", -- Gruvbox comment
          bg0 = "#1D2021", -- Darkest background, used for statuslines, floats, etc.(Often behind popups or bottom bars (e.g., StatusLine, FloatBorder))
          bg1 = "#282828", -- Main editor background
          bg2 = "#32302F", -- Slightly lighter bg, used for subtle UI elements(Used in ColorColumn, folds (Folded), and indent guides)
          bg3 = "#3C3836", -- Used for cursor lines, virtual text, or alternative selection bg(Applies to CursorLine, LineNr, CursorColumn)
          bg4 = "#504945", -- Even lighter bg, often used as border foreground(Used in things like WinSeparator, FloatBorder, or hints)
          bg5 = "#665c54",
          fg1 = "#EBDBB2", -- Main text color, used for normal text
          fg2 = "#D5C4A1", -- Used for subtle text (statuslines, folded code)
          fg3 = "#BDAE93", -- Muted text, used for line numbers, fold columns(Often used in UI (LineNr, NonText, FoldColumn))
          sel0 = "#3C3836", -- Visual selection background, popup backgrounds(Maps to Visual, Pmenu)
          sel1 = "#504945", -- Popup selected item, also used for search highlights(Maps to PmenuSel, Search, IncSearch)
        },
      }
      local specs = {
        nightfox = {
          syntax = {
            -- Identifiers (like variable/function names)
            variable = "fg2",
            -- ident      = "fg1",
            ident = "blue",

            -- Operators and punctuation
            operator = "orange",
            bracket = "#D5C4A1",

            -- Preprocessor (e.g., `@`, macros)
            preproc = "red",

            -- Types and constants
            type = "yellow",
            const = "purple",

            -- Functions
            func = "green",

            -- Keywords and builtins
            keyword = "red",
            builtin0 = "red", -- e.g., `nil`
            builtin1 = "yellow", -- e.g., `List`
            builtin2 = "orange", -- e.g., `true`

            -- Strings and numbers
            string = "green",
            number = "purple",

            -- Comments and statements
            comment = "comment",
            statement = "red",
            conditional = "red",
            loop = "red",

            -- Regex or special strings
            regex = "blue",
          },
        },
      }

      local groups = {
        nightfox = {
          ["@string.special.symbol.elixir"] = { link = "Identifier" }, -- special highlighting for Elixir atoms
          ["@module"] = { link = "Type" },
          GitSignsCurrentLineBlame = { fg = palettes.nightfox.fg2, style = "italic" },

          CmpItemKindCopilot = { fg = "#639EE4" },

          Visual = { bg = palettes.nightfox.bg5 },

          -- make IlluminatedWord* the same as CursorLine, so it doesn't blink during writing
          IlluminatedWordText = { link = "CursorLine" },
          IlluminatedWordRead = { link = "CursorLine" },
          IlluminatedWordWrite = { link = "CursorLine" },

          -- colors for MultiCursor
          VM_Mono = { bg = palettes.nightfox.red, style = "bold" },
          VM_Extend = { bg = palettes.nightfox.orange },
          VM_Cursor = { bg = palettes.nightfox.green },
          VM_Insert = { bg = palettes.nightfox.cyan },

          -- override, as sel0 that is used for selection as well, is too light for autocomplete background
          Pmenu = { bg = palettes.nightfox.bg3 },

          -- highlight group that is used by vim-current-search-match plugin by default
          PmenuSel = { fg = palettes.nightfox.bg2, bg = palettes.nightfox.orange },

          WinSeparator = { link = "Comment" },
          Search = { fg = palettes.nightfox.orange, bg = palettes.nightfox.bg4, style = "bold" },
          IncSearch = { link = "Search" },
          LeapMatch = { link = "Search" },
          LeapLabelPrimary = { link = "Search" },

          -- highlight group that is used by cmp
          CmpItemAbbrDeprecated = { fg = "#808080" },
          CmpItemAbbrMatch = { fg = "#569CD6" },
          CmpItemAbbrMatchFuzzy = { fg = "#569CD6" },
          CmpItemKindVariable = { fg = "#9CDCFE" },
          CmpItemKindInterface = { fg = "#9CDCFE" },
          CmpItemKindText = { fg = "#9CDCFE" },
          CmpItemKindFunction = { fg = "#C586C0" },
          CmpItemKindMethod = { fg = "#C586C0" },
          CmpItemKindKeyword = { fg = "#D4D4D4" },
          CmpItemKindProperty = { fg = "#D4D4D4" },
          CmpItemKindUnit = { fg = "#D4D4D4" },

          -- explicitly set green color, as in the theme this group is linked to itself
          -- https://github.com/EdenEast/nightfox.nvim/blob/a408e6bb101066952b81de9c11be367114bd561f/lua/nightfox/group/modules/nvimtree.lua#L30
          NvimTreeGitStaged = { fg = palettes.nightfox.green },
          -- vim.api.nvim_set_hl(0, "NvimTreeGitStaged", { fg = palettes.nightfox.green })
          -- vim.api.nvim_set_hl(0, "NvimTreeGitNew", { fg = palettes.nightfox.yellow })
          -- vim.api.nvim_set_hl(0, "NvimTreeGitDirty", { fg = palettes.nightfox.pink })
          --
        },
      }
      local options = {
        styles = {
          comments = "italic",
          keywords = "bold",
          types = "italic,bold",
        },
      }

      require("nightfox").setup({
        palettes = palettes,
        specs = specs,
        groups = groups,
        options = options,
      })

      vim.cmd.colorscheme("nightfox")

      vim.opt.termguicolors = true
    end,
  },
}
