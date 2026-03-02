return function()
  lspconfig = require("lspconfig")

  vim.diagnostic.config({
    virtual_text = false,
    severity_sort = true,
    float = {
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  })

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

  local signs = { Error = "", Warning = "", Hint = "", Information = "" }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  local manipulate_pipes = function(direction, client)
    local position_params = vim.lsp.util.make_position_params()

    client.request_sync("workspace/executeCommand", {
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
      local params = vim.lsp.util.make_given_range_params()

      local text = vim.api.nvim_buf_get_text(
        0,
        params.range.start.line,
        params.range.start.character,
        params.range["end"].line,
        params.range["end"].character,
        {}
      )

      local resp = client.request_sync("workspace/executeCommand", {
        command = "expandMacro:serverid",
        arguments = { params.textDocument.uri, vim.fn.join(text, "\n"), params.range.start.line },
      }, nil, 0)

      local content = {}
      if resp["result"] then
        for k, v in pairs(resp.result) do
          vim.list_extend(content, { "# " .. k, "" })
          vim.list_extend(content, vim.split(v, "\n"))
        end
      else
        table.insert(content, "Error")
      end

      vim.schedule(function()
        vim.lsp.util.open_floating_preview(vim.lsp.util.trim_empty_lines(content), "elixir", {})
      end)
    end
  end

  local on_attach = function(client, bufnr)
    -- require 'illuminate'.on_attach(client)

    local bufmap = function(mode, lhs, rhs)
      local opts = { buffer = true }
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    bufmap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", bufopts)
    bufmap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", bufopts)
    bufmap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", bufopts)
    bufmap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", bufopts)
    bufmap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", bufopts)
    bufmap("n", "<space>sh", "<cmd>lua vim.lsp.buf.signature_help()<CR>", bufopts)
    bufmap("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", bufopts)
    bufmap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", bufopts)
    bufmap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", bufopts)
    bufmap("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", bufopts)
    bufmap("n", "<space>f", function()
      vim.lsp.buf.format({ async = true })
    end, bufopts)
    bufmap("n", "<space>q", "<cmd>lua vim.diagnostic.set_loclist()<CR>", bufopts)
    bufmap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", bufopts)
    bufmap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", bufopts)

    bufmap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", bufopts)
    bufmap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", bufopts)
    bufmap("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", bufopts)

    bufmap("n", "<space>tp", ":ElixirToPipe<CR>", bufopts)
    bufmap("n", "<space>fp", ":ElixirFromPipe<CR>", bufopts)
  end

  local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

  -- lspconfig.elixirls.setup({
  vim.lsp.config("elixirls", {
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)

      local add_user_cmd = vim.api.nvim_buf_create_user_command
      vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
        buffer = bufnr,
        callback = vim.lsp.codelens.refresh,
      })
      vim.lsp.codelens.refresh()
      add_user_cmd(bufnr, "ElixirFromPipe", M.from_pipe(client), {})
      add_user_cmd(bufnr, "ElixirToPipe", M.to_pipe(client), {})
      add_user_cmd(bufnr, "ElixirExpandMacro", M.expand_macro(client), { range = true })
    end,
    cmd = { "/Users/vova/projects/elixir-ls/server/language_server.sh" },
    settings = {
      elixirLS = {
        dialyzerEnabled = false,
        fetchDeps = false,
        -- trace = {
        --   server = "verbose"
        -- }
      },
    },
    capabilities = capabilities,
  })

  vim.lsp.config("ts_ls", {
  -- lspconfig.ts_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })

  local function all_env_vars_set(env_variables)
    for _, varName in ipairs(env_variables) do
      if not os.getenv(varName) then
        return false
      end
    end
    return true
  end

  if
    all_env_vars_set({ "DATABASE_HOST", "DATABASE_PORT", "DATABASE_USERNAME", "DATABASE_PASSWORD", "DATABASE_NAME" })
  then
    -- print(
    --   "DSN: host="
    --     .. os.getenv("DATABASE_HOST")
    --     .. " port="
    --     .. os.getenv("DATABASE_PORT")
    --     .. " user="
    --     .. os.getenv("DATABASE_USERNAME")
    --     .. " password="
    --     .. os.getenv("DATABASE_PASSWORD")
    --     .. " dbname="
    --     .. os.getenv("DATABASE_NAME")
    --     .. " sslmode=disable"
    -- )
    local function build_sqls_dsn()
      local vars = {
        DATABASE_HOST = os.getenv("DATABASE_HOST"),
        DATABASE_PORT = os.getenv("DATABASE_PORT"),
        DATABASE_USERNAME = os.getenv("DATABASE_USERNAME"),
        DATABASE_PASSWORD = os.getenv("DATABASE_PASSWORD"),
        DATABASE_NAME = os.getenv("DATABASE_NAME"),
      }

      for k, v in pairs(vars) do
        if not v then
          error("Missing env var: " .. k)
        end
      end

      local dsn = string.format(
        "host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
        vars.DATABASE_HOST,
        vars.DATABASE_PORT,
        vars.DATABASE_USERNAME,
        vars.DATABASE_PASSWORD,
        vars.DATABASE_NAME
      )

      print("DSN: " .. dsn)
      return dsn
    end
    -- lspconfig.sqls.setup({
    vim.lsp.config("sqls", {
      on_attach = function(client, bufnr)
        require("sqls").on_attach(client, bufnr) -- require sqls.nvim
        -- on_attach(client, bufnr)
      end,
      -- cmd = { "sqls" },
      -- root_dir = function()
      --   return vim.loop.cwd() -- або `vim.fn.getcwd()`
      -- end,
      settings = {
        sqls = {
          connections = {
            {
              driver = "postgresql",
              -- dataSourceName = build_sqls_dsn(),
              dataSourceName = "host=127.0.0.1 port=5432 user=postgres password=postgres dbname=prosapient_dev sslmode=disable",
              --   dataSourceName = "host="
              --     .. os.getenv("DATABASE_HOST")
              --     .. " port="
              --     .. os.getenv("DATABASE_PORT")
              --     .. " user="
              --     .. os.getenv("DATABASE_USERNAME")
              --     .. " password="
              --     .. os.getenv("DATABASE_PASSWORD")
              --     .. " dbname="
              --     .. os.getenv("DATABASE_NAME")
              --     .. " sslmode=disable",
            },
          },
        },
      },
    })
  end

  -- vim.lsp.set_log_level("debug")
  vim.lsp.inlay_hint.enable()
  vim.lsp.enable('elixirls')
  vim.lsp.enable('ts_ls')
end
