return {
  -- file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    keys = {
      {
        "<leader>e",
        function()
          local root = vim.fs.root(0, { ".git", "Makefile", "mix.exs", "package.json" })
          require("neo-tree.command").execute({ toggle = true, dir = root or vim.uv.cwd() })
        end,
        desc = "Explorer NeoTree (Root Dir)",
      },
      {
        "<leader>E",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      {
        "<leader>ge",
        function()
          require("neo-tree.command").execute({ source = "git_status", toggle = true })
        end,
        desc = "Git Explorer",
      },
      {
        "<leader>be",
        function()
          require("neo-tree.command").execute({ source = "buffers", toggle = true })
        end,
        desc = "Buffer Explorer",
      },
      {
        "<C-f>",
        function()
          require("neo-tree.command").execute({ reveal = true })
        end,
        desc = "Reveal file in NeoTree",
      },
    },
    deactivate = function()
      vim.cmd([[Neotree close]])
    end,
    init = function()
      -- FIX: use `autocmd` for lazy-loading neo-tree instead of directly requiring it,
      -- because `cwd` is not set up properly.
      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
        desc = "Start Neo-tree with directory",
        once = true,
        callback = function()
          if package.loaded["neo-tree"] then
            return
          else
            local stats = vim.uv.fs_stat(vim.fn.argv(0))
            if stats and stats.type == "directory" then
              require("neo-tree")
            end
          end
        end,
      })
    end,
    opts = {
      sources = { "filesystem", "buffers", "git_status", "document_symbols" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
      -- Глобальні команди — доступні в усіх джерелах (filesystem/buffers/git_status)
      commands = {
        -- moves to the parent directory without collapsing it (h collapses)
        goto_parent = function(state)
          local node = state.tree:get_node()
          local parent_id = node and node:get_parent_id()
          if parent_id then
            require("neo-tree.ui.renderer").focus_node(state, parent_id)
          end
        end,
        mix_test = function(state)
          local path = state.tree:get_node():get_id()
          local root = vim.fs.root(path, { "mix.exs" })
          if not root then
            vim.notify("mix.exs не знайдено для " .. path, vim.log.levels.WARN)
            return
          end
          vim.cmd("botright new")
          vim.fn.jobstart({ "mix", "test", vim.fs.relpath(root, path) or path }, {
            term = true,
            cwd = root,
          })
          vim.cmd("startinsert")
        end,
      },
      -- Групування супутніх файлів під батьківським. Розгортається на <Tab>
      -- (бо дефолтний <space> у нас вимкнений нижче).
      -- Увага: працює лише між файлами в одній директорії.
      nesting_rules = {
        ["mix"] = {
          pattern = "^mix%.exs$",
          files = { "mix.lock" },
        },
        ["elixir"] = {
          pattern = "(.+)%.ex$",
          files = { "%1.html.heex" },
        },
        ["package.json"] = {
          pattern = "^package%.json$",
          files = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb" },
        },
        ["docker"] = {
          pattern = "^dockerfile$",
          ignore_case = true,
          files = { ".dockerignore", "docker-compose.*", "dockerfile*" },
        },
        ["js"] = {
          pattern = "(.+)%.js$",
          files = { "%1.js.map", "%1.min.js", "%1.d.ts" },
        },
        ["ts"] = {
          pattern = "(.+)%.ts$",
          files = { "%1.js", "%1.js.map" },
        },
      },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        -- пошук по всьому шляху, пробіл = ".*": `live dash` знайде
        -- lib/app_web/live/dashboard_live.ex
        find_by_full_path_words = true,
        -- УВАГА: тут Lua-патерни, не глоби (utils/init.lua:591 → string.find)
        filtered_items = {
          always_show_by_pattern = { "^%.env" }, -- .env, .env.local — видно попри hide_dotfiles
          never_show_by_pattern = { "%.beam$" }, -- не видно навіть під `H`
        },
        -- fd не заходить у ці директорії під час fuzzy-пошуку (`F` / `D` / `#`)
        find_args = {
          fd = {
            "--exclude", ".git",
            "--exclude", "_build",
            "--exclude", "deps",
            "--exclude", "node_modules",
            "--exclude", ".elixir_ls",
            "--exclude", ".lexical",
          },
        },
      },
      window = {
        mappings = {
          ["l"] = "open_with_window_picker",
          ["h"] = "close_node",
          ["-"] = { "goto_parent", desc = "Goto parent node" },
          ["<space>"] = "none",
          -- дефолтний toggle_node сидить на <space>, який вимкнений вище —
          -- потрібен, щоб розгортати вкладені файли (nesting_rules)
          ["<Tab>"] = "toggle_node",
          -- `/` віддаємо нативному пошуку Vim (працюють n / N),
          -- fuzzy-фільтр переїжджає на `F`
          ["/"] = "none",
          ["F"] = "fuzzy_finder",
          ["S"] = "split_with_window_picker",
          ["s"] = "vsplit_with_window_picker",
          ["w"] = "open_with_window_picker",
          ["Y"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg("+", path, "c")
            end,
            desc = "Copy Path to Clipboard",
          },
          ["O"] = {
            function(state)
              require("lazy.util").open(state.tree:get_node().path, { system = true })
            end,
            desc = "Open with System Application",
          },
          ["P"] = { "toggle_preview", config = { use_float = false } },
          ["T"] = { "mix_test", desc = "mix test on node" },
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        git_status = {
          symbols = {
            unstaged = "󰄱",
            staged = "󰱒",
          },
        },
      },
    },
    config = function(_, opts)
      local function on_move(data)
        Snacks.rename.on_rename_file(data.source, data.destination)
      end

      local events = require("neo-tree.events")
      opts.event_handlers = opts.event_handlers or {}
      vim.list_extend(opts.event_handlers, {
        { event = events.FILE_MOVED, handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
      })
      require("neo-tree").setup(opts)
      vim.api.nvim_create_autocmd("TermClose", {
        pattern = "*lazygit",
        callback = function()
          if package.loaded["neo-tree.sources.git_status"] then
            require("neo-tree.sources.git_status").refresh()
          end
        end,
      })
    end,
  },
  -- tells LSP servers about file renames/moves/deletes done in neo-tree so
  -- they can update imports (typescript-language-server, lua-language-server)
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neo-tree/neo-tree.nvim", -- makes sure that this loads after Neo-tree.
    },
    config = function()
      require("lsp-file-operations").setup()
    end,
  },
  {
    "s1n7ax/nvim-window-picker",
    version = "2.*",
    config = function()
      require("window-picker").setup({
        hint = "floating-big-letter",
        filter_rules = {
          include_current_win = false,
          autoselect_one = true,
          -- filter using buffer options
          bo = {
            -- if the file type is one of following, the window will be ignored
            filetype = { "neo-tree", "neo-tree-popup", "notify" },
            -- if the buffer type is one of following, the window will be ignored
            buftype = { "terminal", "quickfix" },
          },
        },
      })
    end,
  },
}
