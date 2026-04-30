# Dotfiles

Managed with [Dotbot](https://github.com/anishathalye/dotbot/). Zsh plugins are vendored as git submodules under `zsh/vendor/` and sourced directly from `zshrc` (no plugin manager). Vim plugins use [vim-plug](https://github.com/junegunn/vim-plug) over local submodules.

**Committed content is meant to be generic (“common”)**. Per-machine secrets and environment live in **gitignored** files (see below).

## Prerequisites

- **Git**, **Bash**, **Python 3** (for Dotbot). Prefer **`git clone --recurse-submodules`** so Zsh plugins (`zsh/vendor/`), Vim plugins (`vim/plugins-vendor/`), and Dotbot are present without extra downloads.
- **Zsh** as your login shell (optional but expected by this config)
- **Network is not required at install time** for Meslo fonts (vendored under `fonts/`), Vim plugins (git submodules), or VS Code extensions (vendored `vscode/vsix/*.vsix`).
- **VS Code 1.85.2** (optional): `code` CLI in `PATH`. Extensions install **only** from vendored **`vscode/vsix/*.vsix`** (see `vscode/EXTENSIONS.md`). Use `SKIP_VSCODE_EXTENSIONS=1` to skip the step.

## Install

1. Clone this repository.
2. Run `./install` (idempotent; safe to run again).

**Fonts:** MesloLGS NF **are committed** under `fonts/` (see `fonts/README.md`). `./install` only verifies they exist; no download.

**Fully air-gapped hosts:** Use **`git clone --recurse-submodules`**. Zsh plugins live under **`zsh/vendor/`**, Vim under **`vim/plugins-vendor/`**, VS Code extensions under **`vscode/vsix/`** — no network during `./install` or first zsh start for those layers.

If you already have a `~/.bashrc` you care about, back it up first: Dotbot links `~/.bashrc` to this repo’s `bashrc` with `force: true`.

The `install` script runs `git submodule update --init --recursive` **before** Dotbot, so vendored plugin directories exist before symlinks are created.

### Common vs local (not pushed)

| File / directory | In git? | Purpose |
|------------------|---------|---------|
| **`gitconfig.local.example`** | yes | Template for Git `user.*` |
| **`gitconfig.local`** | **no** | Real identity; created by `cp -n …` on first `./install`, then linked to `~/.gitconfig.local` |
| **`local/env.zsh.example`** | yes | Template for shell env |
| **`local/env.zsh`** | **no** | Proxy, `PATH`, secrets, etc.; sourced at end of `zshrc` |
| **`fonts/MesloLGS NF *.ttf`** | **yes** (recommended) | Vendored Meslo + `MesloLGS NF License.txt` (Apache 2.0) |

Never commit **`gitconfig.local`** or **`local/env.zsh`**.

### Git user identity

`gitconfig` includes `[include] path = ~/.gitconfig.local`. On install, if `gitconfig.local` is missing, it is created from **`gitconfig.local.example`**. Edit **`gitconfig.local`** (repo root, ignored by git) and set `user.name` / `user.email`.

### Dotbot `clean`

`install.conf.yaml` uses `clean: ['~']`, which removes **broken symbolic links** under `$HOME` only. It does not delete ordinary files. See [Dotbot clean](https://github.com/anishathalye/dotbot#clean).

### Vim plugins (non-interactive / CI)

Plugin install uses `vim -E -s … PlugInstall --sync`. If this fails without a TTY, run manually: `vim +PlugInstall +qall`.

> **Air-gapped note**: `vim-easycomplete` ships per-language installer scripts under `vim/plugins-vendor/vim-easycomplete/autoload/easycomplete/installer/*.sh` that download LSP servers (rust-analyzer, jdtls, omnisharp, …) over `curl`. Don't run `:InstallLspServer` on offline hosts; pre-stage the servers manually or skip those completion features.

## Fonts and Powerlevel10k (no garbled icons)

See **`fonts/README.md`** for MesloLGS NF, what is committed vs downloaded, and **server vs Cursor/VS Code** font setup.

Short version for the IDE: in **User** settings JSON on the machine where Cursor/VS Code runs:

```json
{
  "terminal.integrated.fontFamily": "'MesloLGS NF', monospace",
  "terminal.integrated.fontSize": 14
}
```

See also [Powerlevel10k fonts](https://github.com/romkatv/powerlevel10k#fonts).

## Layout

- `install` / `install.conf.yaml` — Dotbot entrypoints
- `zshrc`, `zsh/vendor/*` — Zsh: Oh My Zsh + zsh-autosuggestions + Powerlevel10k + zsh-syntax-highlighting (sourced directly via `$DOTFILES`)
- `vimrc`, `vim/autoload/plug.vim`, `vim/plugins-vendor/*` — Vim + vim-plug (**plugins are git submodules**, wired via local `Plug` paths)
- `fonts/` — Meslo via script; see `fonts/README.md`
- `local/` — optional per-machine `env.zsh`; see `local/README.md`
- `vscode/` — VS Code `settings.json`, `keybindings.json`, pinned `extensions.txt` (target version in `vscode/target-version.txt`); see `vscode/README.md`

## References

- [Dotbot documentation](https://github.com/anishathalye/dotbot/)
- [vim-plug](https://github.com/junegunn/vim-plug/wiki)
- [Powerlevel10k fonts](https://github.com/romkatv/powerlevel10k#fonts)
