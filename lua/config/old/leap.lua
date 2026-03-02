return function()
  vim.keymap.set("n", "gs", function()
    require("leap").leap({
      target_windows = require("leap.user").get_focusable_windows(),
    })
  end)
end
