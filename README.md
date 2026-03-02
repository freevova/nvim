# Neovim Configuration

Personal Neovim configuration focused on Elixir development, with support for TypeScript, SQL, and more.

## Structure

```
~/.config/nvim/
├── init.lua                  # Entry point
├── lua/
│   ├── config/
│   │   ├── options.lua       # Vim options (leader, tabs, folding, etc.)
│   │   ├── lazy.lua          # lazy.nvim bootstrap
│   │   ├── keymaps.lua       # Custom keybindings
│   │   ├── autocmds.lua      # Auto commands
│   │   └── icons.lua         # Icon definitions
│   ├── plugins/
│   │   ├── init.lua          # Snacks.nvim (dashboard, terminal, images)
│   │   ├── lsp.lua           # LSP, completion (blink.cmp), diagnostics
│   │   ├── colorscheme.lua   # Nightfox theme with Gruvbox-inspired colors
│   │   ├── telescope.lua     # Fuzzy finder
│   │   ├── treesitter.lua    # Syntax highlighting & text objects
│   │   ├── editor.lua        # Editing plugins (surround, autopairs, flash, etc.)
│   │   ├── ui.lua            # UI (bufferline, lualine, nvim-tree, etc.)
│   │   ├── git.lua           # Git (fugitive, gitsigns, git-conflict)
│   │   ├── formatting.lua    # conform.nvim formatters
│   │   ├── ai.lua            # Claude Code integration
│   │   └── elixir.lua        # Credo linting via nvim-lint
│   └── debug.lua             # Debug utilities
└── spell/                    # Spell check dictionaries
```

## Key Choices

- **Plugin manager:** [lazy.nvim](https://github.com/folke/lazy.nvim)
- **Completion:** [blink.cmp](https://github.com/saghen/blink.cmp) (LSP, snippets, paths, buffer)
- **Fuzzy finder:** [Telescope](https://github.com/nvim-telescope/telescope.nvim) with fzf-native
- **Theme:** [Nightfox](https://github.com/EdenEast/nightfox.nvim) customized with Gruvbox palette
- **File tree:** [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua)
- **Status line:** [lualine](https://github.com/nvim-lualine/lualine.nvim)
- **Formatting:** [conform.nvim](https://github.com/stevearc/conform.nvim) — stylua, prettier, mix format, ruff, pg_format
- **AI:** [claudecode.nvim](https://github.com/coder/claudecode.nvim)

## LSP

| Language   | Server                          | Notes                              |
|------------|---------------------------------|------------------------------------|
| Elixir     | ElixirLS (local build)          | Code lens, pipe manipulation, macro expansion |
| TypeScript | ts_ls                           | Standard setup                     |
| SQL        | sqls                            | PostgreSQL, auto-configured via env vars |

Treesitter parsers auto-installed for ~25 languages (Elixir, TypeScript, Python, Lua, Bash, HTML, JSON, YAML, and more).

## Keybindings

Leader: `,` | Local leader: `\`

### General

| Key | Action |
|-----|--------|
| `jj` | Exit insert mode |
| `<C-h/j/k/l>` | Navigate splits |
| `\|` | Vertical split |
| `_` | Horizontal split |
| `<leader><space>` | Clear search highlighting |
| `<leader>r` | Cycle line number modes |

### Finding

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep (with args) |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |
| `<leader>fs` | LSP document symbols |
| `<C-p>` | Toggle file tree |
| `<C-F>` | Reveal current file in tree |

### LSP

| Key | Action |
|-----|--------|
| `K` | Hover docs |
| `gd` / `gD` | Go to definition / declaration |
| `gi` / `gr` | Go to implementation / references |
| `<space>rn` | Rename |
| `<space>ca` | Code action |
| `<space>f` | Format buffer |
| `<space>e` | Diagnostic float |
| `[d` / `]d` | Prev / next diagnostic |

### Elixir

| Key | Action |
|-----|--------|
| `<space>tp` | To pipe |
| `<space>fp` | From pipe |

### Git

| Key | Action |
|-----|--------|
| `]c` / `[c` | Next / prev hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghb` | Blame line |
| `<leader>ghd` | Diff this |

### Testing

| Key | Action |
|-----|--------|
| `<space>tn` | Test nearest |
| `<space>tf` | Test file |
| `<space>tl` | Test last |

### Claude Code

| Key | Action |
|-----|--------|
| `<leader>ac` | Toggle Claude |
| `<leader>as` | Send selection to Claude |
| `<leader>ab` | Add current buffer |
| `<leader>aa` / `<leader>ad` | Accept / deny diff |

### Navigation

| Key | Action |
|-----|--------|
| `s` / `S` | Flash jump / treesitter jump |
| `]f` / `[f` | Next / prev function |
| `]a` / `[a` | Next / prev parameter |
| `<S-h>` / `<S-l>` | Prev / next buffer |
| `-` | Toggle switch (assert/refute, and/or, etc.) |

## Requirements

- Neovim >= 0.10
- [ripgrep](https://github.com/BurntSushi/ripgrep) for Telescope live grep
- A [Nerd Font](https://www.nerdfonts.com/) for icons
- Language-specific:
  - **Elixir:** ElixirLS built at `~/projects/elixir-ls/`
  - **Formatting:** stylua, prettier, pg_format, ruff installed and on PATH
  - **Python:** pyenv with 3.13.3 (configured in options)
