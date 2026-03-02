return function()
  local npairs = require("nvim-autopairs")
  local endwise = require("nvim-autopairs.ts-rule").endwise

  npairs.setup()
  npairs.add_rules({
    endwise("then$", "end", "lua", nil),
  })
end
