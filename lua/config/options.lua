-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.mapleader = "," -- leader key
vim.g.maplocalleader = "\\" -- leader key
vim.g.python3_host_prog = "~/.pyenv/versions/3.13.3/bin/python3"


-- Show the current document symbols location from Trouble in lualine
-- You can disable this for a buffer by setting `vim.b.trouble_lualine = false`
vim.g.trouble_lualine = true

vim.o.mouse = "a" -- mouse support
vim.o.shell = "/bin/zsh"
vim.o.whichwrap = vim.o.whichwrap .. "<,>,h,l" -- Wrap movement between lines in edit mode with arrows
vim.wo.colorcolumn = "120" -- shows vertical bar

local opt = vim.opt

opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus" -- Sync with system clipboard
opt.undofile = true -- save undo changes between sessions
opt.backup = false -- does not make a backup before overwriting a file
opt.writebackup = false -- does not make a backup before overwriting a file
opt.swapfile = false -- does not use swapfile for the buffer
opt.autoread = true -- autoreload files (when change git branch)
opt.title = true -- show filename in title
opt.scrolloff = 4 -- minimum indentation from top/bottom of screen to highlighted result on searching
opt.sidescrolloff = 8 -- Columns of context
opt.number = true -- print the line number in front of each line
opt.rnu = true -- print relative line numbers
opt.history = 1000 -- size of the saved command-lines in a history table
opt.wrap = false -- disable wrapping strings (when they are very long)
opt.list = true -- show tabs as CTRL-I is displayed
opt.listchars = "tab:▷⋅,trail:⋅,nbsp:⋅" -- strings to use in 'list' mode
opt.splitbelow = true -- open split window below
opt.splitright = true -- open split window right
opt.hidden = true -- allow hidden files
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorcolumn = true -- highlights whole column under cursor
opt.cursorline = true -- highlights whole line under cursor
opt.tabstop = 2 -- number of spaces for tab
opt.shiftwidth = 2 -- number of spaces to use for each step of (auto)indent
opt.shiftround = true -- Round indent
opt.smartindent = true -- Insert indents automatically
opt.softtabstop = 2 -- number of spaces that a <Tab> counts for while performing editing operations
opt.expandtab = true -- use the appropriate number of spaces to insert a <Tab> in the insert mode
opt.smarttab = true --  only even number of spaces (3 spaces + tab = 4 spaces, 2 spaces + tab = 4 spaces)
opt.ignorecase = true -- ignore case in search patterns
opt.smartcase = true -- override the 'ignorecase' option if the search pattern contains upper case characters
opt.fillchars = "vert:▏" -- characters to fill the statuslines and vertical separators
opt.diffopt = "filler,internal,algorithm:histogram,indent-heuristic" -- option settings for diff mode
opt.signcolumn = "yes" -- reserve a column for language client/gitgutter notifications even if nothing to show
opt.modeline = true -- https://www.cs.swarthmore.edu/oldhelp/vim/modelines.html
opt.modelines = 5 -- sets the number of lines (at the beginning and end of each file) vim checks for initializations
opt.encoding = "utf-8" -- set default encoding to utf-8
opt.spelllang = { "en_gb" } -- set spell languages
opt.hlsearch = true -- Highlight found searches
opt.incsearch = true -- Shows the match while typing
opt.joinspaces = false -- No double spaces with join
opt.linebreak = true -- Stop words being broken on wrap
opt.showmode = false -- Don't display mode
opt.smoothscroll = true
opt.guicursor =
  "n-v-c-sm:block-blinkwait50-blinkon50-blinkoff50,i-ci-ve:ver25-Cursor-blinkon100-blinkoff100,r-cr-o:hor20" -- sets blinking guicursor
opt.foldmethod = "expr" -- use expression for folding
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- gives the fold level of a line.
opt.foldenable = false -- Disable folding at startup.
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width

vim.api.wildmenu = true -- command-mode completion
vim.api.wildignorecase = true -- wildmenu ignores case
