return {
  -- syntax aware text-objects, select, move, swap, and peek support.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    event = { "BufReadPre", "BufNewFile" },
    version = false, -- last release is way too old and doesn't work on Windows
    -- lazy = false,
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "bash",
        "css",
        "diff",
        "eex",
        "elixir",
        "erlang",
        "graphql",
        "haskell",
        "html",
        "heex",
        "javascript",
        "java",
        "json",
        "lua",
        "markdown",
        "pug",
        "python",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
    },
    config = function(_, opts)
      -- `main` has no modules: parsers are installed explicitly (no-op when
      -- present) and highlighting/indentation are enabled per buffer. pcall
      -- skips filetypes without a parser; treesitter indent is used only where
      -- an indents query ships, otherwise the legacy indent script stays.
      require("nvim-treesitter").install(opts.ensure_installed)
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          if not pcall(vim.treesitter.start, ev.buf) then return end
          local lang = vim.treesitter.language.get_lang(ev.match)
          if lang and vim.treesitter.query.get(lang, "indents") then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end
  },
  -- syntax aware text-objects, select, move, swap, and peek support.
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")

      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      -- Select textobjects
      local select_maps = {
        { "af", "@function.outer", "Select outer function" },
        { "if", "@function.inner", "Select inner function" },
        { "ac", "@class.outer", "Select outer class" },
        { "ic", "@class.inner", "Select inner class" },
      }
      for _, m in ipairs(select_maps) do
        local key, query, desc = unpack(m)
        vim.keymap.set({ "x", "o" }, key, function()
          select.select_textobject(query)
        end, { desc = desc })
      end

      -- Move: goto next/previous start/end
      local move_maps = {
        { "goto_next_start", "]f", "@function.outer", "Next function start" },
        { "goto_next_start", "]c", "@class.outer", "Next class start" },
        { "goto_next_start", "]a", "@parameter.inner", "Next parameter start" },
        { "goto_next_end", "]F", "@function.outer", "Next function end" },
        { "goto_next_end", "]C", "@class.outer", "Next class end" },
        { "goto_next_end", "]A", "@parameter.inner", "Next parameter end" },
        { "goto_previous_start", "[f", "@function.outer", "Prev function start" },
        { "goto_previous_start", "[c", "@class.outer", "Prev class start" },
        { "goto_previous_start", "[a", "@parameter.inner", "Prev parameter start" },
        { "goto_previous_end", "[F", "@function.outer", "Prev function end" },
        { "goto_previous_end", "[C", "@class.outer", "Prev class end" },
        { "goto_previous_end", "[A", "@parameter.inner", "Prev parameter end" },
      }
      for _, m in ipairs(move_maps) do
        local fn_name, key, query, desc = unpack(m)
        vim.keymap.set({ "n", "x", "o" }, key, function()
          move[fn_name](query)
        end, { desc = desc })
      end

      -- Swap
      vim.keymap.set("n", "<leader>cn", function()
        swap.swap_next("@parameter.inner")
      end, { desc = "Swap parameter with next" })
      vim.keymap.set("n", "<leader>cN", function()
        swap.swap_previous("@parameter.inner")
      end, { desc = "Swap parameter with previous" })
    end,
  },

  -- Show context of the current function
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = function()
      local tsc = require("treesitter-context")
      Snacks.toggle({
        name = "Treesitter Context",
        get = tsc.enabled,
        set = function(state)
          if state then
            tsc.enable()
          else
            tsc.disable()
          end
        end,
      }):map("<leader>ut")
      return { mode = "cursor", max_lines = 5 }
    end,
  },
  -- provides alternating syntax highlighting (“rainbow parentheses”) for Neovim
  { 
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" } 
  },
}

