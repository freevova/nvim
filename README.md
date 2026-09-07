# Neovim Configuration

Personal Neovim configuration focused on Elixir development, with support for TypeScript, SQL, and more.

## Structure

```
~/.config/nvim/
├── init.lua                        # Entry point
├── lua/
│   ├── config/
│   │   ├── options.lua             # Vim options (leader, tabs, folding, diff, etc.)
│   │   ├── lazy.lua                # lazy.nvim bootstrap
│   │   ├── keymaps.lua             # Global keybindings
│   │   ├── autocmds.lua            # Auto commands
│   │   ├── icons.lua               # Icon definitions (diagnostics, git, kinds, folders)
│   │   ├── elixir_doc_blocks.lua   # Band behind @doc/@moduledoc, iex> examples as Elixir
│   │   └── debug.lua               # _G.dump helper
│   └── plugins/
│       ├── init.lua                # Snacks.nvim (dashboard, terminal, images, toggles)
│       ├── lsp.lua                 # LSP servers, diagnostics, LspAttach keymaps
│       ├── completion.lua          # blink.cmp + friendly-snippets
│       ├── diagnostics.lua         # Trouble, todo-comments, nvim-lint, nvim-bqf
│       ├── colorscheme.lua         # Nightfox theme with Gruvbox-inspired colors
│       ├── telescope.lua           # Fuzzy finder
│       ├── treesitter.lua          # Syntax highlighting, text objects, context, rainbow
│       ├── editor.lua              # surround, autopairs, flash, which-key, yanky
│       ├── ui.lua                  # bufferline, lualine, indent-blankline, markdown
│       ├── neo-tree.lua            # File explorer
│       ├── git.lua                 # fugitive, gitsigns, git-conflict
│       ├── formatting.lua          # conform.nvim formatters
│       ├── test.lua                # vim-test through tslime
│       └── ai.lua                  # Claude Code integration
├── queries/elixir_doc/             # Highlights for the elixir_doc language alias
├── after/queries/markdown/         # iex> injection inside @doc blocks
└── spell/                          # Spell check dictionaries
```

## Key Choices

- **Plugin manager:** [lazy.nvim](https://github.com/folke/lazy.nvim)
- **Completion:** [blink.cmp](https://github.com/saghen/blink.cmp) (LSP, snippets, paths, buffer)
- **Fuzzy finder:** [Telescope](https://github.com/nvim-telescope/telescope.nvim) with fzf-native
- **Theme:** [Nightfox](https://github.com/EdenEast/nightfox.nvim) customized with Gruvbox palette
- **File tree:** [neo-tree](https://github.com/nvim-neo-tree/neo-tree.nvim) with window-picker
- **Status line:** [lualine](https://github.com/nvim-lualine/lualine.nvim)
- **Diagnostics list:** [Trouble](https://github.com/folke/trouble.nvim), quickfix previews via [nvim-bqf](https://github.com/kevinhwang91/nvim-bqf)
- **Formatting:** [conform.nvim](https://github.com/stevearc/conform.nvim) — stylua, oxfmt, typos, mix format, ruff, pg_format
- **Linting:** [nvim-lint](https://github.com/mfussenegger/nvim-lint) — Credo, only where `.credo.exs` exists
- **AI:** [claudecode.nvim](https://github.com/coder/claudecode.nvim)

## LSP

| Language        | Server                    | Notes                                                        |
|-----------------|---------------------------|--------------------------------------------------------------|
| Elixir          | Expert                    | `elixirSourcePath` derived from the `elixir` on PATH, so `gd` reaches stdlib sources |
| HEEx / EEx      | html, emmet, tailwindcss  | Expert reads HEEx as Elixir text; these add tags, abbreviations and class names |
| TypeScript      | ts_ls                     | Inlay hints enabled, toggle with `<leader>uh`                |
| SQL             | sqls                      | PostgreSQL, configured only when `DATABASE_*` env vars are set |

ElixirLS stays configured in `lsp.lua` as a fallback but is not enabled; exactly one Elixir server runs at a time.
Formatting is left to `mix format`, so the HTML server starts with `provideFormatter = false`.

Treesitter parsers auto-installed for 25 languages (Elixir, HEEx, EEx, TypeScript, Python, Lua, Bash, HTML, JSON, YAML, and more).

## Keybindings

Leader: `,` | Local leader: `\` | `<leader>?` shows the buffer-local keymaps, `<c-w><space>` the window hydra.

### General

| Key | Action |
|-----|--------|
| `jj` | Exit insert mode |
| `<C-h/j/k/l>` | Navigate splits (also from terminal mode) |
| `\|` | Vertical split |
| `_` | Horizontal split |
| `<leader><space>` | Clear search highlighting |
| `<leader>r` | Cycle line number modes |
| `/` | Search with `\v` (very magic) prepended |
| `-` | Switch opposite term (assert/refute, and/or, required/optional) |
| `===` | Format buffer |

### Search

| Key | Action |
|-----|--------|
| `<leader>sf` | Find files |
| `<leader>sg` | Live grep |
| `<leader>sb` | Buffers |
| `<leader>sh` | Help tags |
| `<leader>ss` / `<leader>sS` | Document / workspace symbols |
| `<leader>sr` | Search and replace across files (grug-far) |
| `<leader>sp` | Yank history |
| `<leader>st` / `<leader>sT` | Todo comments / only TODO, FIX, FIXME |

### Files

| Key | Action |
|-----|--------|
| `<leader>e` / `<leader>E` | Explorer at project root / cwd |
| `<C-f>` | Reveal current file in the explorer |
| `<leader>ge` | Git status explorer |
| `<leader>be` | Buffer explorer |

Inside the tree: `l`/`h` open/close, `-` parent, `<Tab>` toggle node, `F` fuzzy filter (`/` stays Vim search),
`w`/`s`/`S` open in a picked window / vertical / horizontal split, `P` preview, `Y` copy path,
`O` open with system app, `T` `mix test` on the node.

### LSP

Hover, tag jumps, document symbols and diagnostic motions stay on Neovim defaults (`K`, `<C-]>`, `gO`, `]d`/`[d`).
Everything else lives under `gl`, the which-key "lsp" group, and is mapped only if the server implements it.

| Key | Action |
|-----|--------|
| `gd` / `gD` | Go to definition / declaration |
| `gld` | Peek definition — into quickfix, previewed by nvim-bqf |
| `gla` | Code action |
| `gln` | Rename |
| `glr` / `gli` / `glt` | References / implementation / type definition |
| `glR` | References, definitions and more, in a Trouble window |
| `gls` | Signature help |
| `gle` | Line diagnostics float |
| `glq` / `glQ` | Execute SQL query / vertical (sqls buffers, operator-pending) |

Diagnostics of the cursor line open in a float on `CursorHold`; there is no virtual text, so the layout never shifts.

### Diagnostics & quickfix

| Key | Action |
|-----|--------|
| `<leader>xx` / `<leader>xX` | Diagnostics / buffer diagnostics (Trouble) |
| `<leader>xL` / `<leader>xQ` | Location list / quickfix (Trouble) |
| `<leader>xt` / `<leader>xT` | Todos / only TODO, FIX, FIXME (Trouble) |
| `gs` | Symbols (Trouble) |
| `]q` / `[q` | Next / prev Trouble or quickfix item |
| `]t` / `[t` | Next / prev todo comment |

### Git

| Key | Action |
|-----|--------|
| `]h` / `[h` | Next / prev hunk (vim's `]c`/`[c` inside a diff) |
| `<leader>gs` / `<leader>gr` | Stage / reset hunk (also over a selection) |
| `<leader>gS` / `<leader>gR` | Stage / reset buffer |
| `<leader>gp` / `<leader>gi` | Preview hunk in a float / inline |
| `<leader>gb` | Blame line, full |
| `<leader>gd` / `<leader>gD` | Diff this / against `~` |
| `<leader>gq` / `<leader>gQ` | Hunks / all hunks to quickfix |
| `<leader>ub` / `<leader>uw` | Toggle line blame / word diff |
| `ih` | Hunk text object |
| `<leader>gco` / `gct` / `gcb` / `gcn` | Conflict: choose ours / theirs / both / none |
| `<leader>gcB` / `<leader>gcl` | Conflict: choose base / list to quickfix |
| `]x` / `[x` | Next / prev conflict |

Diff windows paint the old side red: the `Diff*` groups are the new side and `*AsDelete` variants are swapped in
per window through `winhighlight` (`config/autocmds.lua` for `fugitive://` and `gitsigns://` buffers).

### Buffers

| Key | Action |
|-----|--------|
| `gb` / `gB` | Next / prev buffer |
| `]b` / `[b` | Next / prev buffer |
| `]B` / `[B` | Move buffer right / left |
| `<leader>bp` / `<leader>bP` | Toggle pin / delete non-pinned |
| `<leader>br` / `<leader>bl` | Delete buffers to the right / left |

### Navigation & text objects

| Key | Action |
|-----|--------|
| `g/` | Flash jump |
| `r` / `R` | Remote flash (operator) / treesitter search |
| `<c-space>` | Treesitter incremental selection |
| `]f` / `[f`, `]F` / `[F` | Next / prev function start, end |
| `]c` / `[c`, `]C` / `[C` | Next / prev class start, end (hunk motions in a diff window) |
| `]a` / `[a`, `]A` / `[A` | Next / prev parameter start, end |
| `af` / `if`, `ac` / `ic` | Select outer / inner function, class |
| `gx` | Open with system app |

### Change

| Key | Action |
|-----|--------|
| `<leader>ca` / `<leader>cA` | Add surrounding / on new lines (also over a selection) |
| `<leader>cl` / `<leader>cL` | Surround line / on new lines |
| `<leader>cd` / `<leader>cr` / `<leader>cR` | Delete / replace surrounding / on new lines |
| `<C-g>s` / `<C-g>S` | Add surrounding from insert mode |
| `<leader>cn` / `<leader>cN` | Swap parameter with next / previous |

### Testing

| Key | Action |
|-----|--------|
| `<leader>tn` | Test nearest |
| `<leader>tf` | Test file |
| `<leader>tl` | Test last |

### Claude Code

| Key | Action |
|-----|--------|
| `<leader>ac` / `<leader>af` | Toggle / focus Claude |
| `<C-,>` | Focus Claude |
| `<leader>ar` / `<leader>aC` | Resume / continue a session |
| `<leader>ab` | Add current buffer |
| `<leader>as` | Send selection, or add the file under the cursor in the tree |
| `<leader>aa` / `<leader>ad` | Accept / deny diff |

### UI toggles

| Key | Action |
|-----|--------|
| `<leader>uh` | Inlay hints |
| `<leader>ut` | Treesitter context |
| `<leader>um` | Render markdown |
| `<leader>up` | Markdown preview in the browser |
| `<leader>ub` / `<leader>uw` | Git line blame / word diff |

## Requirements

- Neovim >= 0.11 — `vim.lsp.config`/`vim.lsp.enable`, `winborder` and `vim.uv` are all 0.11 APIs
- [ripgrep](https://github.com/BurntSushi/ripgrep) for Telescope live grep
- A [Nerd Font](https://www.nerdfonts.com/) for icons
- Language-specific:
  - **Elixir:** [Expert](https://github.com/elixir-lang/expert) at `~/.local/bin/expert`; Credo linting needs a `.credo.exs` in the project
  - **HEEx:** `vscode-html-language-server`, `emmet-language-server`, `tailwindcss-language-server` — installed through mise's npm backend so they do not depend on the node version a project pins
  - **TypeScript:** `typescript-language-server`
  - **SQL:** `sqls`, plus `DATABASE_HOST`, `DATABASE_USERNAME`, `DATABASE_PASSWORD`, `DATABASE_NAME` exported in the project (direnv); `DATABASE_PORT` defaults to 5432
  - **Formatting:** stylua, oxfmt, typos, pg_format, ruff installed and on PATH
