return {
  -- Neovim plugin for sqls that leverages the built-in LSP client
  -- not lazy: its lsp/sqls.lua must be on the runtimepath when vim.lsp.config("sqls") is resolved
  { "nanotee/sqls.nvim", lazy = false },

  -- collection of common configurations for built-in language server client
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local icons = require("config.icons")

      vim.diagnostic.config({
        severity_sort = true,
        virtual_text = false,
        float = { source = true, header = "", prefix = "" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
          },
        },
      })

      -- show the diagnostics of the cursor line in a float once the cursor rests
      -- (updatetime); no virtual text, so the layout never shifts
      vim.api.nvim_create_autocmd("CursorHold", {
        group = vim.api.nvim_create_augroup("diagnostic_float", { clear = true }),
        callback = function()
          vim.diagnostic.open_float(nil, { focusable = false, scope = "line" })
        end,
      })

      -- applies to every server, including the ones configured by plugins (sqls)
      vim.lsp.config("*", {
        capabilities = vim.tbl_deep_extend(
          "force",
          require("blink.cmp").get_lsp_capabilities(),
          require("lsp-file-operations").default_capabilities()
        ),
      })

      -- ElixirLS-only commands, driven through workspace/executeCommand
      local manipulate_pipes = function(direction, client)
        local position_params = vim.lsp.util.make_position_params(0, client.offset_encoding)

        client:request_sync("workspace/executeCommand", {
          command = "manipulatePipes:serverid",
          arguments = {
            direction,
            position_params.textDocument.uri,
            position_params.position.line,
            position_params.position.character,
          },
        }, nil, 0)
      end

      local function expand_macro(client)
        local params = vim.lsp.util.make_given_range_params(nil, nil, 0, client.offset_encoding)

        local text = vim.api.nvim_buf_get_text(
          0,
          params.range.start.line,
          params.range.start.character,
          params.range["end"].line,
          params.range["end"].character,
          {}
        )

        local resp = client:request_sync("workspace/executeCommand", {
          command = "expandMacro:serverid",
          arguments = { params.textDocument.uri, vim.fn.join(text, "\n"), params.range.start.line },
        }, nil, 0)

        local content = {}
        if resp["result"] then
          for k, v in pairs(resp.result) do
            vim.list_extend(content, { "# " .. k, "" })
            vim.list_extend(content, vim.split(v, "\n", { trimempty = true }))
          end
        else
          table.insert(content, "Error")
        end

        vim.schedule(function()
          vim.lsp.util.open_floating_preview(content, "elixir", {})
        end)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
        callback = function(ev)
          local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
          local bufnr = ev.buf

          -- vim-illuminate highlights via treesitter, and no server here has
          -- lenses worth showing (Expert: "Reindex" in mix.exs, ElixirLS: tests)
          client.server_capabilities.documentHighlightProvider = false
          client.server_capabilities.codeLensProvider = nil

          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
          end
          -- only map what this server actually implements, so which-key never
          -- shows a key that would answer "method not supported"
          local lsp_map = function(method, mode, lhs, rhs, desc)
            if client:supports_method(method) then
              map(mode, lhs, rhs, desc)
            end
          end

          -- Hover, definition-by-tag, document symbols and diagnostic jumps stay
          -- on Neovim defaults (K, <C-]>, gO, ]d/[d). Everything else is under
          -- gl, the which-key "lsp" group; Neovim's gr* defaults are removed
          -- below so `gr` (replace virtual char) works without a timeout.
          lsp_map("textDocument/definition", "n", "gd", vim.lsp.buf.definition, "Goto definition")
          lsp_map("textDocument/declaration", "n", "gD", vim.lsp.buf.declaration, "Goto declaration")

          lsp_map("textDocument/codeAction", { "n", "x" }, "gla", vim.lsp.buf.code_action, "Code action")
          lsp_map("textDocument/rename", "n", "gln", vim.lsp.buf.rename, "Rename")
          lsp_map("textDocument/references", "n", "glr", vim.lsp.buf.references, "References")
          lsp_map("textDocument/implementation", "n", "gli", vim.lsp.buf.implementation, "Implementation")
          lsp_map("textDocument/typeDefinition", "n", "glt", vim.lsp.buf.type_definition, "Type definition")
          -- definition(s) into quickfix instead of jumping, so nvim-bqf previews
          -- the code in a float while the cursor stays here
          lsp_map("textDocument/definition", "n", "gld", function()
            vim.lsp.buf.definition({
              on_list = function(list)
                vim.fn.setqflist({}, " ", list)
                vim.cmd.copen()
              end,
            })
          end, "Peek definition")
          lsp_map("textDocument/signatureHelp", "n", "gls", vim.lsp.buf.signature_help, "Signature help")
          map("n", "gle", vim.diagnostic.open_float, "Line diagnostics")

          if client.name == "elixirls" then
            local add_user_cmd = vim.api.nvim_buf_create_user_command
            add_user_cmd(bufnr, "ElixirFromPipe", function()
              manipulate_pipes("fromPipe", client)
            end, {})
            add_user_cmd(bufnr, "ElixirToPipe", function()
              manipulate_pipes("toPipe", client)
            end, {})
            add_user_cmd(bufnr, "ElixirExpandMacro", function()
              expand_macro(client)
            end, { range = true })
          end

          if client.name == "sqls" then
            -- <Plug>(sqls-execute-query) is an operator: glqip runs the paragraph
            map({ "n", "x" }, "glq", "<Plug>(sqls-execute-query)", "Execute query")
            map({ "n", "x" }, "glQ", "<Plug>(sqls-execute-query-vertical)", "Execute query, vertical")
          end
        end,
      })

      for _, lhs in ipairs({ "grn", "grr", "gri", "grt", "grx" }) do
        pcall(vim.keymap.del, "n", lhs)
      end
      pcall(vim.keymap.del, { "n", "x" }, "gra")

      vim.lsp.config("elixirls", {
        cmd = { vim.fn.expand("~/projects/elixir-ls/server/language_server.sh") },
        -- mix.lock exists only at the umbrella root, so nested apps resolve to it;
        -- a function is needed because lspconfig's default root_dir would otherwise
        -- win over root_markers
        root_dir = function(bufnr, on_dir)
          local root = vim.fs.root(bufnr, { "mix.lock", ".git" })
          if root then
            on_dir(root)
          end
        end,
        settings = {
          elixirLS = {
            dialyzerEnabled = false,
            fetchDeps = false,
            suggestSpecs = false,
            enableTestLenses = false,
            mixEnv = "dev",
          },
        },
      })

      -- inlay hints need explicit preferences for typescript-language-server
      local ts_inlay_hints = {
        includeInlayParameterNameHints = "literals",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      }
      vim.lsp.config("ts_ls", {
        settings = {
          typescript = { inlayHints = ts_inlay_hints },
          javascript = { inlayHints = ts_inlay_hints },
        },
      })

      -- Expert reads HEEx as Elixir text: it completes inside {} and <%= %> but
      -- knows no tags, attributes or components, so html and emmet cover those.
      -- Formatting stays with mix format
      vim.lsp.config("html", {
        filetypes = { "html", "heex", "eelixir" },
        init_options = { provideFormatter = false },
      })
      vim.lsp.config("emmet_language_server", {
        filetypes = { "html", "css", "scss", "javascriptreact", "typescriptreact", "heex", "eelixir" },
        -- emmet only knows its own syntaxes, map the Elixir templates onto html
        init_options = { includeLanguages = { heex = "html", eelixir = "html" } },
      })
      -- lspconfig falls back to .git as the root for Tailwind v4, which would start
      -- a server in every Elixir project; only projects that pull in tailwind get one
      vim.lsp.config("tailwindcss", {
        root_dir = function(bufnr, on_dir)
          local util = require("lspconfig.util")
          local fname = vim.api.nvim_buf_get_name(bufnr)
          local markers = {
            "tailwind.config.js",
            "tailwind.config.cjs",
            "tailwind.config.mjs",
            "tailwind.config.ts",
            "postcss.config.js",
            "postcss.config.cjs",
            "postcss.config.mjs",
            "postcss.config.ts",
          }
          markers = util.insert_package_json(markers, "tailwindcss", fname)
          markers = util.root_markers_with_field(markers, { "mix.lock" }, "tailwind", fname)
          local root = vim.fs.find(markers, { path = fname, upward = true })[1]
          if root then
            on_dir(vim.fs.dirname(root))
          end
        end,
      })

      -- Elixir install root (has lib/elixir/lib/kernel.ex) derived from the elixir
      -- on PATH: mise builds are compiled on CI, so module sources point to
      -- /home/runner/...; Expert remaps them onto this root for stdlib gd
      local function elixir_source_path()
        local exe = vim.fn.exepath("elixir")
        if exe == "" then
          return nil
        end
        local root = vim.fs.dirname(vim.fs.dirname(vim.fn.resolve(exe)))
        if vim.uv.fs_stat(root .. "/lib/elixir/lib/kernel.ex") then
          return root
        end
      end

      -- Expert, the official Elixir LSP. cmd, filetypes and the umbrella-aware
      -- root_dir come from lspconfig's lsp/expert.lua. Settings are a flat map,
      -- that is how Expert reads workspace/didChangeConfiguration.
      vim.lsp.config("expert", {
        settings = {
          -- do not run mix deps.get behind my back when the engine fails to start
          autoFetchDependencies = false,
          elixirSourcePath = elixir_source_path(),
        },
      })

      local function all_env_vars_set(env_variables)
        for _, varName in ipairs(env_variables) do
          if not os.getenv(varName) then
            return false
          end
        end
        return true
      end

      -- sqls is only configured inside a project that exports DATABASE_* vars
      -- (direnv in platform-backend); the port is optional there
      if all_env_vars_set({ "DATABASE_HOST", "DATABASE_USERNAME", "DATABASE_PASSWORD", "DATABASE_NAME" }) then
        -- commands and <Plug> maps come from sqls.nvim's own lsp/sqls.lua on_attach
        vim.lsp.config("sqls", {
          settings = {
            sqls = {
              connections = {
                {
                  driver = "postgresql",
                  dataSourceName = ("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable"):format(
                    os.getenv("DATABASE_HOST"),
                    os.getenv("DATABASE_PORT") or "5432",
                    os.getenv("DATABASE_USERNAME"),
                    os.getenv("DATABASE_PASSWORD"),
                    os.getenv("DATABASE_NAME")
                  ),
                },
              },
            },
          },
        })
        vim.lsp.enable("sqls")
      end

      vim.lsp.inlay_hint.enable()
      Snacks.toggle.inlay_hints():map("<leader>uh")
      -- elixirls stays configured as a fallback; enable exactly one Elixir server
      vim.lsp.enable("expert")
      vim.lsp.enable("ts_ls")
      vim.lsp.enable({ "html", "emmet_language_server", "tailwindcss" })
    end,
  },

  -- notifications and LSP progress messages
  { "j-hui/fidget.nvim", event = "LspAttach", config = true },
}
