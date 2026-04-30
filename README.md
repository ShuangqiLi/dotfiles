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

### Updating an air-gapped host (sneakernet)

Air-gapped boxes can't `git pull` or fetch new submodules from GitHub. After you push changes from a connected machine (especially when **submodule pointers move** or a **new submodule** is added), use `scripts/package-for-offline.sh` to ship a self-contained tarball:

**On the connected machine** (with network + a clone of this repo):

```bash
cd ~/dotfiles
git pull
scripts/package-for-offline.sh         # add NO_PULL=1 to skip the implicit pull
# -> writes ../dotfiles-<sha>-<timestamp>.tar.gz
```

The tarball includes the working tree **plus `.git/` and all `.git/modules/<sub>/`** — that is, the main repo's git db AND every submodule's git db pre-populated. (The script refuses to package if any submodule worktree is missing, so you can't accidentally ship a broken bundle.)

**Transfer** the tarball to the offline host (USB, jump host, `scp`, whatever your environment allows).

**On the air-gapped host:**

```bash
mv ~/dotfiles ~/dotfiles.bak.$(date +%s)         # back up current checkout
tar -xzf dotfiles-<sha>-<timestamp>.tar.gz -C ~/ # extracts as ~/dotfiles
cd ~/dotfiles
./install
```

Because the tarball already contains every submodule's git db and worktree at the right SHA, the `git submodule update --init --recursive` that `./install` runs is a no-op — no network. After install, follow-up runs are idempotent (~9s on a converged box).

> **Tip:** If you just want to refresh files without keeping git history, `tar --exclude='.git/*' …` cuts the archive size roughly in half, but the offline host then can't run any git commands locally. Keep `.git/` for `git log`, `git diff`, etc.

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

### Vim plugins

Vim plugins are git submodules under `vim/plugins-vendor/`, loaded by **vim-plug** as local paths (`Plug '~/.vim/plugins-vendor/<name>'`). `plug#end()` puts each one on `&runtimepath` at startup, so **no `PlugInstall` is needed** — the installer does not run it (it would only trigger git/job probing that fails on air-gapped hosts).

Make sure submodules are populated before running `./install`:

```bash
git clone --recurse-submodules <repo>
# or, in an existing checkout:
git submodule update --init --recursive
```

> **Air-gapped note**: `vim-easycomplete` ships per-language installer scripts under `vim/plugins-vendor/vim-easycomplete/autoload/easycomplete/installer/*.sh` that download LSP servers (rust-analyzer, jdtls, omnisharp, …) over `curl`. Don't run `:InstallLspServer` on offline hosts; pre-stage the servers manually or skip those completion features.

### Prompt theme: P10k with P9K fallback for old zsh

Powerlevel10k requires `zsh >= 5.1`. If `$ZSH_VERSION` is older (e.g. **5.0.2** on stock RHEL/CentOS 7 where you can't upgrade zsh), `zshrc` automatically falls back to its predecessor **Powerlevel9k**:

- `zsh/vendor/powerlevel10k/` (submodule) — used on zsh ≥ 5.1, configured via `~/.p10k.zsh`.
- `zsh/vendor/powerlevel9k/` (submodule) — used on zsh < 5.1, configured via `~/.p9k.zsh` (rainbow-style preset roughly matching the P10k preset). Edit `p9k.zsh` in the repo.

Both presets expect MesloLGS NF (vendored under `fonts/`). The Powerlevel10k instant-prompt cache block in `zshrc` is also gated on zsh ≥ 5.1, so the "minimum required version is 5.1" warning will not appear on older hosts.

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
- `zshrc`, `zsh/vendor/*` — Zsh: Oh My Zsh + zsh-autosuggestions + Powerlevel10k (with Powerlevel9k fallback on zsh < 5.1) + zsh-syntax-highlighting (sourced directly via `$DOTFILES`)
- `vimrc`, `vim/autoload/plug.vim`, `vim/plugins-vendor/*` — Vim + vim-plug (**plugins are git submodules**, wired via local `Plug` paths)
- `fonts/` — Meslo via script; see `fonts/README.md`
- `local/` — optional per-machine `env.zsh`; see `local/README.md`
- `vscode/` — VS Code `settings.json`, `keybindings.json`, pinned `extensions.txt` (target version in `vscode/target-version.txt`); see `vscode/README.md`
- `scripts/package-for-offline.sh` — produce a self-contained tarball (working tree + `.git/modules/*`) for sneakernet to air-gapped hosts; see "Updating an air-gapped host" above

## References

- [Dotbot documentation](https://github.com/anishathalye/dotbot/)
- [vim-plug](https://github.com/junegunn/vim-plug/wiki)
- [Powerlevel10k fonts](https://github.com/romkatv/powerlevel10k#fonts)
