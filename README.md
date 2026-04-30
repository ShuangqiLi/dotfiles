# Dotfiles

Managed with [Dotbot](https://github.com/anishathalye/dotbot/). Zsh plugins use [Antidote](https://github.com/mattmc3/antidote); Vim plugins use [vim-plug](https://github.com/junegunn/vim-plug).

**Committed content is meant to be generic (“common”)**. Per-machine secrets and environment live in **gitignored** files (see below).

## Prerequisites

- **Git**, **Bash**, **Python 3** (for Dotbot)
- **Zsh** as your login shell (optional but expected by this config)
- **curl** or network access for submodules, Vim plugins, and **optional** Meslo download (skipped when TTFs are already in `fonts/`)
- **Build toolchain** for [fzf](https://github.com/junegunn/fzf) if you use the bundled `fzf/install` step (see fzf docs)
- **VS Code** (optional): `code` CLI in `PATH`. For **offline** targets, run **`scripts/fetch-vscode-vsix.sh`** on a connected machine and **commit `vscode/vsix/*.vsix`** so `./install` never hits the Marketplace. See **`vscode/README.md`**. Use `SKIP_VSCODE_EXTENSIONS=1` to skip the step.

## Install

1. Clone this repository.
2. Run `./install` (idempotent; safe to run again).

**Fonts:** MesloLGS NF **can live in git** (see `fonts/README.md` + `MesloLGS NF License.txt`). After you add the four `*.ttf` once, `./install` skips downloading them. If download still fails on a fresh machine, use `SKIP_MESLO_FONTS=1 ./install` or copy TTFs in by hand.

**Fully air-gapped hosts:** VS Code extensions are covered if you **vendor `vscode/vsix/*.vsix`** (see `vscode/README.md`). Other steps may still expect network the first time (e.g. **Git submodules**, **vim `PlugInstall`**, **Antidote** cloning plugins when you open zsh, **fzf** build). For a sealed environment, vendor those artifacts too or set skips (`SKIP_MESLO_FONTS`, `SKIP_VSCODE_EXTENSIONS`, etc.) and pre-populate caches as needed.

If you already have a `~/.bashrc` you care about, back it up first: Dotbot links `~/.bashrc` to this repo’s `bashrc` with `force: true`.

The `install` script runs `git submodule update --init --recursive` **before** Dotbot, so paths like `antidote/` exist before symlinks are created.

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

### Optional tools

- **fzf** preview alias `fls`: nicer previews if `rougify`, `highlight`, or `coderay` are installed.
- **`cf`**: requires `locate` (e.g. `plocate`) and an up-to-date database (`updatedb` / `plocate-build`).

## Layout

- `install` / `install.conf.yaml` — Dotbot entrypoints
- `zshrc`, `zsh_plugins.txt` — Zsh + Antidote + Powerlevel10k
- `vimrc`, `vim/autoload/plug.vim` — Vim + vim-plug (plugins under `~/.cache/vim/plugged`)
- `fonts/` — Meslo via script; see `fonts/README.md`
- `local/` — optional per-machine `env.zsh`; see `local/README.md`
- `vscode/` — VS Code `settings.json`, `keybindings.json`, pinned `extensions.txt` (target version in `vscode/target-version.txt`); see `vscode/README.md`

## References

- [Dotbot documentation](https://github.com/anishathalye/dotbot/)
- [Antidote](https://antidote.sh)
- [vim-plug](https://github.com/junegunn/vim-plug/wiki)
- [Powerlevel10k fonts](https://github.com/romkatv/powerlevel10k#fonts)
