-- Elixir documentation blocks (@doc/@moduledoc/@typedoc/@shortdoc):
--  * a full-width darker band behind each block (ElixirDocBlock group), kept
--    as one line_hl_group extmark per block and refreshed after text changes.
--    A decoration provider would be lighter, but Neovim 0.12 does not render
--    ephemeral line_hl_group marks, so the marks are persistent.
--  * `iex>` examples inside the docs are parsed as Elixir under the
--    `elixir_doc` language alias (after/queries/markdown/injections.scm);
--    its highlight groups are the theme's Elixir colours blended halfway into
--    the band background, so example code reads as documentation.
local ns = vim.api.nvim_create_namespace("elixir_doc_blocks")
local group = vim.api.nvim_create_augroup("elixir_doc_blocks", { clear = true })
local timers = {}
local query

local parser_path = vim.api.nvim_get_runtime_file("parser/elixir.so", false)[1]
if parser_path then
  pcall(vim.treesitter.language.add, "elixir_doc", { path = parser_path, symbol_name = "elixir" })
end

local function doc_query()
  if not query then
    query = vim.treesitter.query.parse(
      "elixir",
      [[
        (unary_operator
          operator: "@"
          operand: (call
            target: (identifier) @_name
            (arguments [(string) (charlist) (sigil)] @doc))
          (#any-of? @_name "doc" "moduledoc" "typedoc" "shortdoc"))
      ]]
    )
  end
  return query
end

local function refresh(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "elixir" then
    return
  end
  local parser = vim.treesitter.get_parser(bufnr, "elixir", { error = false })
  if not parser then
    return
  end
  local tree = parser:parse()[1]
  if not tree then
    return
  end
  local q = doc_query()
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  for id, node in q:iter_captures(tree:root(), bufnr) do
    if q.captures[id] == "doc" then
      local start_row, _, end_row = node:range()
      vim.api.nvim_buf_set_extmark(bufnr, ns, start_row, 0, {
        end_row = end_row,
        end_col = 0,
        line_hl_group = "ElixirDocBlock",
      })
    end
  end
end

local function schedule(bufnr)
  local timer = timers[bufnr]
  if not timer then
    timer = vim.uv.new_timer()
    timers[bufnr] = timer
  end
  timer:stop()
  timer:start(80, 0, vim.schedule_wrap(function()
    refresh(bufnr)
  end))
end

local function blend(fg, bg, amount)
  local function channel(color, shift)
    return bit.band(bit.rshift(color, shift), 0xff)
  end
  local out = 0
  for _, shift in ipairs({ 16, 8, 0 }) do
    local mixed = channel(fg, shift) * (1 - amount) + channel(bg, shift) * amount
    out = out + bit.lshift(math.floor(mixed + 0.5), shift)
  end
  return out
end

-- Same lookup the highlighter does: "@a.b.c" falls back to "@a.b", then "@a".
local function base_group(capture)
  local parts = vim.split(capture, ".", { plain = true })
  for i = #parts, 1, -1 do
    local name = "@" .. table.concat(parts, ".", 1, i)
    for _, candidate in ipairs({ name .. ".elixir", name }) do
      if vim.fn.hlexists(candidate) == 1 then
        return vim.api.nvim_get_hl(0, { name = candidate, link = false })
      end
    end
  end
  return {}
end

local dim_defined = false
local function define_dim_groups()
  local ok, q = pcall(vim.treesitter.query.get, "elixir_doc", "highlights")
  if not ok or not q then
    return
  end
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local band = vim.api.nvim_get_hl(0, { name = "ElixirDocBlock", link = false })
  local bg = band.bg or normal.bg
  if not bg or not normal.fg then
    return
  end
  local skip = { spell = true, nospell = true, conceal = true, none = true }
  for _, capture in ipairs(q.captures) do
    if not skip[capture] and not capture:match("^_") then
      local base = base_group(capture)
      vim.api.nvim_set_hl(0, "@" .. capture .. ".elixir_doc", {
        fg = blend(base.fg or normal.fg, bg, 0.5),
        italic = base.italic,
      })
    end
  end
  dim_defined = true
end

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "elixir", "markdown" },
  callback = function()
    if not dim_defined then
      define_dim_groups()
    end
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = function()
    if dim_defined then
      define_dim_groups()
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "elixir",
  callback = function(ev)
    refresh(ev.buf)
    if vim.b[ev.buf].elixir_doc_blocks_attached then
      return
    end
    vim.b[ev.buf].elixir_doc_blocks_attached = true
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TextChangedP" }, {
      group = group,
      buffer = ev.buf,
      callback = function()
        schedule(ev.buf)
      end,
    })
    vim.api.nvim_create_autocmd("BufWipeout", {
      group = group,
      buffer = ev.buf,
      callback = function()
        local timer = timers[ev.buf]
        if timer then
          timer:stop()
          timer:close()
          timers[ev.buf] = nil
        end
      end,
    })
  end,
})
