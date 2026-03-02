return function()
  require("copilot").setup({
    suggestion = { enabled = false },
    panel = { enabled = false },
    copilot_node_command = '/Users/vova/.local/share/mise/installs/node/23.11.0/bin/node', -- Node.js version must be > 22
  })
end
