local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  -- only helper windows without their own q; Trouble, neo-tree, Lazy and
  -- man already close on q
  pattern = {
    "checkhealth",
    "fugitive",
    "fugitiveblame",
    "git",
    "gitsigns-blame",
    "grug-far",
    "help",
    "qf",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(event.buf) then
        return
      end
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- the Diff* groups are painted for the new side of a diff, so repaint the
-- HEAD/index side red. fugitive:// and gitsigns:// buffers are always that side
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = augroup("diff_old_side"),
  pattern = { "fugitive://*", "gitsigns://*" },
  callback = function()
    vim.wo.winhighlight = "DiffAdd:DiffAddAsDelete,DiffChange:DiffChangeAsDelete,DiffText:DiffTextAsDelete"
  end,
})
