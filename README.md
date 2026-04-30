# Dotfiles

Self-contained, **offline-first** dotfiles. No plugin manager, no submodules, no external tools at install time — `./install` is a small bash script that symlinks files into `$HOME` and runs a few post-link hooks.

**Committed content is meant to be generic (“common”)**. Per-machine secrets and environment live in **gitignored** files (see below).

## Prerequisites

- **Git**, **Bash 4.2+** (RHEL 7 fine), **coreutils**.
- **Zsh** as your login shell (optional but expected by this config).
- **Network is not required at install time** for any layer:
  - **Vim plugins** live under `vim/plugins-vendor/<name>/` as plain files (no submodules, no git history).
  - **Zsh plugins** live under `zsh/vendor/<name>/` likewise.
  - **MesloLGS NF fonts** are vendored under `fonts/`.
  - **VS Code 1.85.2 extensions** are vendored as `vscode/vsix/*.vsix`; `code` CLI must be on `PATH` (or set `VSCODE_CLI`). `SKIP_VSCODE_EXTENSIONS=1` skips the step.

## Install

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
./install        # idempotent; ~3s on a converged box
```

`./install` delegates to `scripts/install.sh` (a small bash dotbot replacement) which:

1. Creates `gitconfig.local` from `gitconfig.local.example` if it doesn't exist.
2. Removes broken top-level symlinks under `$HOME`.
3. Symlinks the dotfiles into `$HOME` (`~/.vimrc`, `~/.vim`, `~/.zshrc`, `~/.bashrc`, `~/.p10k.zsh`, `~/.p9k.zsh`, `~/.gitconfig`, `~/.gitconfig.local`, `~/.gitignore_global`, `~/.fonts`, `~/.config/Code/User/settings.json`, `~/.config/Code/User/keybindings.json`).
4. Verifies vendored Meslo fonts and refreshes `fc-cache`.
5. Reconciles vendored VSIX with `code --list-extensions` and only re-installs extensions whose pinned version differs.

Knobs:

| Env var                  | Effect |
|--------------------------|--------|
| `DRY_RUN=1`              | print actions, do not modify the filesystem |
| `SKIP_MESLO_FONTS=1`     | skip the font-presence check + `fc-cache` step |
| `SKIP_VSCODE_EXTENSIONS=1` | skip the VS Code extension step |
| `VSCODE_CLI=/path/to/code` | override VS Code CLI auto-detect |

`~/.bashrc` and `~/.gitconfig.local` are linked with `force` semantics: existing **non-symlink** files at those paths are removed without backup. Back them up first if you care.

### Updating an air-gapped host (sneakernet)

Air-gapped boxes can't `git pull`. Since the repo is now plain files (no submodules), packaging is just `tar`:

**On a connected machine:**

```bash
cd ~/dotfiles
git pull
scripts/package-for-offline.sh             # writes ../dotfiles-<sha>-<ts>.tar.gz
# or, smaller (no .git history, ~130 MB instead of ~420 MB):
NO_GIT=1 scripts/package-for-offline.sh
```

**On the offline host:**

```bash
mv ~/dotfiles ~/dotfiles.bak.$(date +%s)
tar -xzf dotfiles-<sha>-<ts>.tar.gz -C ~/
cd ~/dotfiles && ./install
```

There is no `git submodule update` step anywhere — the vendor dirs are just files. Subsequent `./install` runs are idempotent (~3s).

### Updating a vendored plugin / theme

Run on a network-connected host:

```bash
scripts/update-vendor.sh <vendor-path> <git-url> [<ref>]
# Examples:
scripts/update-vendor.sh vim/plugins-vendor/nerdtree https://github.com/preservim/nerdtree.git master
scripts/update-vendor.sh zsh/vendor/powerlevel10k    https://github.com/romkatv/powerlevel10k.git v1.20.0
```

The script clones the upstream repo, removes its `.git/`, replaces the target directory with the snapshot, and stages the diff. Review with `git diff --cached <path>` and commit:

```bash
git commit -m "chore(vendor): update <path> to <ref>"
```

### Common vs local (not pushed)

| File / directory               | In git? | Purpose |
|--------------------------------|---------|---------|
| **`gitconfig.local.example`**  | yes     | Template for Git `user.*` |
| **`gitconfig.local`**          | **no**  | Real identity; created from the template on first install |
| **`local/env.zsh.example`**    | yes     | Template for shell env |
| **`local/env.zsh`**            | **no**  | Proxy, `PATH`, secrets, etc.; sourced at end of `zshrc` |
| **`fonts/MesloLGS NF *.ttf`**  | yes     | Vendored Meslo + `MesloLGS NF License.txt` (Apache 2.0) |

Never commit **`gitconfig.local`** or **`local/env.zsh`**.

### Vim plugins

Plugins live as plain directories under `vim/plugins-vendor/<name>/` and are loaded by **vim-plug** via local paths in `vimrc`:

```vim
Plug '~/.vim/plugins-vendor/nerdtree'
" ...
```

`plug#end()` puts each one on `&runtimepath` at startup, so **no `PlugInstall` is needed**.

> **Air-gapped note**: `vim-easycomplete` ships per-language installer scripts under `vim/plugins-vendor/vim-easycomplete/autoload/easycomplete/installer/*.sh` that download LSP servers (rust-analyzer, jdtls, omnisharp, …) via `curl`. Don't run `:InstallLspServer` on offline hosts; pre-stage the servers manually or skip those completion features.

### Prompt theme: P10k with P9K fallback for old zsh

Powerlevel10k requires `zsh >= 5.1`. If `$ZSH_VERSION` is older (e.g. **5.0.2** on stock RHEL/CentOS 7 where you can't upgrade zsh), `zshrc` automatically falls back to its predecessor **Powerlevel9k**:

- `zsh/vendor/powerlevel10k/` — used on zsh ≥ 5.1, configured via `~/.p10k.zsh`.
- `zsh/vendor/powerlevel9k/`  — used on zsh < 5.1, configured via `~/.p9k.zsh` (rainbow-style preset roughly matching the P10k preset). Edit `p9k.zsh` in the repo.

Both presets expect MesloLGS NF (vendored under `fonts/`). The Powerlevel10k instant-prompt cache block in `zshrc` is also gated on zsh ≥ 5.1, so the "minimum required version is 5.1" warning will not appear on older hosts.

## Fonts and Powerlevel10k (no garbled icons)

See **`fonts/README.md`** for MesloLGS NF, what is committed, and **server vs Cursor/VS Code** font setup.

Short version for the IDE: in **User** settings JSON on the machine where Cursor/VS Code runs:

```json
{
  "terminal.integrated.fontFamily": "'MesloLGS NF', monospace",
  "terminal.integrated.fontSize": 14
}
```

See also [Powerlevel10k fonts](https://github.com/romkatv/powerlevel10k#fonts).

## Layout

- `install`, `scripts/install.sh` — bash entrypoint + dotbot replacement (no submodules, no Python)
- `scripts/install-meslo-fonts.sh`, `scripts/install-vscode-extensions.sh` — post-link hooks
- `scripts/package-for-offline.sh` — sneakernet tarball helper
- `scripts/update-vendor.sh` — refresh a vendored dir from a git URL (network-connected only)
- `zshrc`, `zsh/vendor/*` — Zsh: Oh My Zsh + zsh-autosuggestions + Powerlevel10k (with Powerlevel9k fallback on zsh < 5.1) + zsh-syntax-highlighting (sourced directly via `$DOTFILES`)
- `vimrc`, `vim/autoload/plug.vim`, `vim/plugins-vendor/*` — Vim + vim-plug + vendored plugins (plain dirs)
- `fonts/` — vendored MesloLGS NF; see `fonts/README.md`
- `local/` — optional per-machine `env.zsh`; see `local/README.md`
- `vscode/` — VS Code `settings.json`, `keybindings.json`, pinned `extensions.txt` (target version in `vscode/target-version.txt`); see `vscode/README.md`

## References

- [vim-plug](https://github.com/junegunn/vim-plug/wiki)
- [Powerlevel10k fonts](https://github.com/romkatv/powerlevel10k#fonts)
- [Powerlevel9k stylizing](https://github.com/Powerlevel9k/powerlevel9k/wiki/Stylizing-Your-Prompt)
