return function()
  require("ibl").setup({
    whitespace = { remove_blankline_trail = true },
    indent = { char = "┊" },
    exclude = {
      filetypes = {
        -- default
        "lspinfo",
        "packer",
        "checkhealth",
        "help",
        "man",
        "gitcommit",
        "TelescopePrompt",
        "TelescopeResults",
        "",
      },
    },
  })
end
