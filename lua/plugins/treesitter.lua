return {
  -- syntax aware text-objects, select, move, swap, and peek support.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
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

      -- Incremental selection using treesitter nodes (vim.treesitter core API)
      local node_at_cursor = nil
      local function get_node_range(node)
        local sr, sc, er, ec = node:range()
        return sr, sc, er, ec
      end

      local function select_node(node)
        if not node then return end
        local sr, sc, er, ec = get_node_range(node)
        vim.api.nvim_buf_set_mark(0, "<", sr + 1, sc, {})
        vim.api.nvim_buf_set_mark(0, ">", er + 1, ec - 1, {})
        vim.cmd("normal! gv")
      end

      vim.keymap.set("n", "<C-space>", function()
        local node = vim.treesitter.get_node()
        if node then
          node_at_cursor = node
          select_node(node)
        end
      end, { desc = "Init treesitter selection" })

      vim.keymap.set("v", "<C-space>", function()
        if node_at_cursor then
          local parent = node_at_cursor:parent()
          if parent then
            node_at_cursor = parent
            select_node(parent)
          end
        end
      end, { desc = "Expand to parent node" })

      vim.keymap.set("v", "<BS>", function()
        if node_at_cursor then
          local child = node_at_cursor:child(0)
          if child then
            node_at_cursor = child
            select_node(child)
          end
        end
      end, { desc = "Shrink to child node" })
    end
  },
  -- syntax aware text-objects, select, move, swap, and peek support.
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
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
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      }
      for key, query in pairs(select_maps) do
        vim.keymap.set({ "x", "o" }, key, function()
          select.select_textobject(query)
        end)
      end

      -- Move: goto next/previous start/end
      local move_maps = {
        goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
        goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
        goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
        goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
      }
      for fn_name, mappings in pairs(move_maps) do
        for key, query in pairs(mappings) do
          vim.keymap.set({ "n", "x", "o" }, key, function()
            move[fn_name](query)
          end)
        end
      end

      -- Swap
      vim.keymap.set("n", "<leader>xp", function() swap.swap_next("@parameter.inner") end)
      vim.keymap.set("n", "<leader>xP", function() swap.swap_previous("@parameter.inner") end)
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
    dependencies = { "nvim-treesitter/nvim-treesitter" } 
  },
}

