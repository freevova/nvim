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
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        virtual_text = false,
        float = {
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
          },
        },
      })

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

      local M = {}

      function M.from_pipe(client)
        return function()
          manipulate_pipes("fromPipe", client)
        end
      end

      function M.to_pipe(client)
        return function()
          manipulate_pipes("toPipe", client)
        end
      end

      function M.expand_macro(client)
        return function()
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
      end

      local on_attach = function(client, bufnr)
        client.server_capabilities.documentHighlightProvider = false
        client.server_capabilities.codeLensProvider = nil

        local bufmap = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end

        -- Hover, definition-by-tag, document symbols and diagnostic jumps stay
        -- on Neovim defaults (K, <C-]>, gO, ]d/[d). Everything else is under
        -- gl, the which-key "lsp" group; Neovim's gr* defaults are removed
        -- below so `gr` (replace virtual char) works without a timeout.
        bufmap("n", "gd", vim.lsp.buf.definition, "Goto definition")
        bufmap("n", "gD", vim.lsp.buf.declaration, "Goto declaration")

        bufmap({ "n", "x" }, "gla", vim.lsp.buf.code_action, "Code action")
        bufmap("n", "gln", vim.lsp.buf.rename, "Rename")
        bufmap("n", "glr", vim.lsp.buf.references, "References")
        bufmap("n", "gli", vim.lsp.buf.implementation, "Implementation")
        bufmap("n", "glt", vim.lsp.buf.type_definition, "Type definition")
        -- definition(s) into quickfix instead of jumping, so nvim-bqf previews
        -- the code in a float while the cursor stays here
        bufmap("n", "gld", function()
          vim.lsp.buf.definition({
            on_list = function(list)
              vim.fn.setqflist({}, " ", list)
              vim.cmd.copen()
            end,
          })
        end, "Peek definition")
        bufmap("n", "gle", vim.diagnostic.open_float, "Line diagnostics")
        bufmap("n", "gls", vim.lsp.buf.signature_help, "Signature help")
        bufmap("n", "glp", ":ElixirToPipe<CR>", "To pipe")
        bufmap("n", "glP", ":ElixirFromPipe<CR>", "From pipe")

        bufmap("n", "glwa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
        bufmap("n", "glwr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
        bufmap("n", "glwl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, "List workspace folders")
      end

      for _, lhs in ipairs({ "grn", "grr", "gri", "grt", "grx" }) do
        pcall(vim.keymap.del, "n", lhs)
      end
      pcall(vim.keymap.del, { "n", "x" }, "gra")

      local capabilities = vim.tbl_deep_extend(
        "force",
        require("blink.cmp").get_lsp_capabilities(),
        require("lsp-file-operations").default_capabilities()
      )

      vim.lsp.config("elixirls", {
        on_attach = function(client, bufnr)
          on_attach(client, bufnr)

          local add_user_cmd = vim.api.nvim_buf_create_user_command
          add_user_cmd(bufnr, "ElixirFromPipe", M.from_pipe(client), {})
          add_user_cmd(bufnr, "ElixirToPipe", M.to_pipe(client), {})
          add_user_cmd(bufnr, "ElixirExpandMacro", M.expand_macro(client), { range = true })
        end,
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
        flags = {
          debounce_text_changes = 150,
        },
        capabilities = capabilities,
      })

      vim.lsp.config("ts_ls", {
        on_attach = on_attach,
        capabilities = capabilities,
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
        on_attach = on_attach,
        capabilities = capabilities,
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

        -- <Plug>(sqls-execute-query) is an operator: glqip runs the paragraph
        vim.api.nvim_create_autocmd("LspAttach", {
          group = vim.api.nvim_create_augroup("sqls_keys", { clear = true }),
          callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            if client and client.name == "sqls" then
              local function map(lhs, rhs, desc)
                vim.keymap.set({ "n", "x" }, lhs, rhs, { buffer = ev.buf, desc = desc })
              end
              map("glq", "<Plug>(sqls-execute-query)", "Execute query")
              map("glQ", "<Plug>(sqls-execute-query-vertical)", "Execute query, vertical")
            end
          end,
        })
      end

      vim.lsp.inlay_hint.enable()
      -- elixirls stays configured as a fallback; enable exactly one Elixir server
      vim.lsp.enable("expert")
      vim.lsp.enable("ts_ls")
    end,
  },

  -- show signature from LSP when apply a function
  {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    config = function()
      require("lsp_signature").setup({
        hint_prefix = " ",
        transparency = 10,
      })
    end,
  },

  -- notifications and LSP progress messages
  { "j-hui/fidget.nvim", event = "LspAttach", config = true },

  -- completion engine
  {
    "saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "rafamadriz/friendly-snippets" },
    version = "1.*",
    opts = {
      keymap = {
        preset = "none",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-u>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<C-d>"] = { "snippet_forward", "fallback" },
        ["<C-b>"] = { "snippet_backward", "fallback" },
      },
      appearance = { nerd_font_variant = "mono", kind_icons = require("config.icons").kinds },
      completion = {

        accept = {
          -- experimental auto-brackets support
          auto_brackets = {
            enabled = true,
          },
        },
        ghost_text = {
          enabled = vim.g.ai_cmp,
        },
        documentation = { auto_show = true, window = { border = "rounded" } },
        menu = {
          -- draw = {
          --   treesitter = { "lsp" },
          -- },
          draw = {
            components = {
              kind_icon = {
                text = function(ctx)
                  local icon = ctx.kind_icon
                  if vim.tbl_contains({ "Path" }, ctx.source_name) then
                      local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                      if dev_icon then
                          icon = dev_icon
                      end
                  end

                  return icon .. ctx.icon_gap
                end,

                -- Optionally, use the highlight groups from nvim-web-devicons
                -- You can also add the same function for `kind.highlight` if you want to
                -- keep the highlight groups in sync with the icons.
                highlight = function(ctx)
                  local hl = ctx.kind_hl
                  if vim.tbl_contains({ "Path" }, ctx.source_name) then
                    local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                    if dev_icon then
                      hl = dev_hl
                    end
                  end
                  return hl
                end,
              }
            }
          }
        }
      },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },

  -- better design for quick-fix window, it is used in easygrep, vim-fugitive, etc
  { "kevinhwang91/nvim-bqf", ft = "qf" },
}
