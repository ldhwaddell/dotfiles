# Dotfiles

Personal macOS configuration for Homebrew Bash, Git, Ghostty, and Neovim 0.12+.

## Bootstrap

Install Homebrew first, then install the declared command-line environment:

```bash
./brew.sh
./install.sh --dry-run
./install.sh
```

`install.sh` backs up conflicting files under `~/.dotfiles-backup/<timestamp>/` before linking. Running it repeatedly is safe. When `nvim` is on `PATH` it also runs a headless startup so `vim.pack` installs the pinned plugins; otherwise they install on the first interactive launch.

Useful options:

```bash
./brew.sh --upgrade     # Upgrade Brewfile packages and stable Rust
./brew.sh --set-shell   # Register and select Homebrew Bash
./install.sh --dry-run  # Preview links and backups
```

The Brewfile cleanup report is advisory. The scripts never uninstall packages that are not declared in this repository.

## Rust

Rust is managed by Homebrew's `rustup` package. The bootstrap selects the stable toolchain and the shell path exposes Homebrew's rustup proxies and `$HOME/.cargo/bin`.

```bash
rustup show active-toolchain
rustc --version
cargo --version
```

## Neovim

The configuration targets Neovim 0.12 or newer and supports Lua, JavaScript/TypeScript, Python, Markdown, Rust, JSON/HTML, SQL, Bash, and Vimscript.

Plugins are managed by the built-in `vim.pack` and install to `~/.local/share/nvim/site/pack/core/opt`. `tools/nvim/nvim-pack-lock.json` pins every plugin revision and is committed, so a fresh checkout reproduces the same versions.

Language tooling is installed via Homebrew, plus `rustup` components for Rust:

- LSP: LuaLS, StyLua, tsc, Oxlint, Ruff, ty, and rust-analyzer
- Formatting: StyLua, Oxfmt, Ruff, mdformat, sql-formatter, and rustfmt
- Linting: Markdownlint, Oxlint, and shellcheck (Bash)

StyLua intentionally runs both as an LSP server and as the Lua formatter.

Searching uses fzf-lua, alongside mini.nvim, blink.cmp, conform, nvim-lint, nvim-treesitter, gitsigns, neo-tree, and which-key. All Git commands live under `<leader>g`: `<leader>gg` opens lazygit, `<leader>gf` shows the current file's history, `<leader>gl` opens the log, and the hunk actions are `<leader>gs`/`<leader>gr` (stage/reset), `<leader>gu` (undo stage), `<leader>gS`/`<leader>gR` (whole buffer), `<leader>gp` (preview), `<leader>gb` (blame), and `<leader>gd`/`<leader>gD` (diff against the index/last commit). Files opened with `e` from lazygit open in a vertical split of the parent Neovim; multi-selecting files and filenames containing a single quote are not supported (the latter shows lazygit's error popup). lazygit reads `tools/lazygit/config.yml` through the linked `~/Library/Application Support/lazygit/config.yml`. Undo history and diffs use the built-in `:Undotree` and `:DiffTool`, and the interface uses `ui2`.

Search pickers also cover registers (`<leader>s"`), marks (`<leader>sm`), jumps (`<leader>sj`), command history (`<leader>s:`), and the quickfix stack (`<leader>sq`). Utility keymaps toggle spell (`<leader>us`), restart LSP clients (`<leader>ul`), open `:checkhealth vim.lsp` (`<leader>uL`), update plugins (`<leader>up`), and restart Neovim (`<leader>uR`). mini.move uses Option+hjkl to move the current line in Normal mode or selected text in Visual mode; Ghostty passes Option through as Alt with `macos-option-as-alt = true`. Spell is on for Markdown and git commit buffers.

Maintenance and diagnostics:

```vim
" Review the update buffer, then :write to apply and :restart to load
:lua vim.pack.update()
:checkhealth dotfiles
:checkhealth vim.pack
:checkhealth vim.lsp
:checkhealth nvim-treesitter
```

The headless smoke test covers startup, filetypes, LSP, formatting, and linting:

```bash
bash tools/nvim/scripts/smoke.sh
```

`ast-grep` is installed as a command-line structural search and rewrite tool. It is not coupled to a Neovim plugin or global `sgconfig.yml`.

## Ghostty

Ghostty reads `tools/ghostty/config.ghostty` through the linked `~/.config/ghostty` directory.

## macOS preferences

macOS defaults are opt-in. Preview them first:

```bash
./macos.sh
./macos.sh --apply
```

The script does not request administrator privileges and no longer resets Launchpad data.

## Local overrides

Machine-specific or private Bash settings can live in `~/.extra`; the login profile sources it when present.
