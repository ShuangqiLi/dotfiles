# Dotfiles

Self-contained, **offline-first** dotfiles. No plugin manager, no submodules, no external tools at install time — `./install` is a small bash script that symlinks files into `$HOME` and runs a few post-link hooks.

**Committed content is meant to be generic (“common”)**. Per-machine secrets and environment live in **gitignored** files (see [Common vs local](#common-vs-local-not-pushed)).

## Repo layout

The root has only folders plus `install` and `README.md`:

```
.
├── install                # bash entrypoint -> scripts/install.sh
├── README.md
├── bash/                  # bashrc (hands off to zsh when present)
├── git/                   # gitconfig, gitignore_global, gitconfig.local{,.example}
├── zsh/                   # zshrc, p10k.zsh, p9k.zsh, vendor/* (oh-my-zsh, p10k, p9k, …)
├── vim/                   # vimrc, autoload/plug.vim, plugins-vendor/*
├── vscode/                # settings.json, keybindings.json, extensions.txt, vsix/
├── fonts/                 # MesloLGS NF + license
├── local/                 # gitignored per-machine env.zsh + example template
└── scripts/               # install.sh, package-for-offline.sh, update-vendor.sh, …
```

`./install` only links these files into `$HOME` (see the table inside `scripts/install.sh`). Vendor directories under `zsh/vendor/` and `vim/plugins-vendor/` are committed as plain files — no git submodules, no upstream history.

## Prerequisites

- **Git**, **Bash 4.2+** (RHEL 7 fine), **coreutils**.
- **Zsh** as your login shell (optional but expected by this config).
- **Network is not required at install time** for any layer:
  - **Zsh plugins** live under `zsh/vendor/<name>/` as plain files.
  - **Vim plugins** live under `vim/plugins-vendor/<name>/` as plain files.
  - **MesloLGS NF fonts** are vendored under `fonts/`.
  - **VS Code 1.85.2 extensions** are vendored as `vscode/vsix/*.vsix`; `code` CLI must be on `PATH` (or set `VSCODE_CLI`). `SKIP_VSCODE_EXTENSIONS=1` skips the step.

## Install

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
./install        # idempotent; ~3s on a converged box
```

`./install` delegates to `scripts/install.sh` (a small bash dotbot replacement) which:

1. Creates `git/gitconfig.local` from `git/gitconfig.local.example` if it doesn't exist.
2. Removes broken top-level symlinks under `$HOME`.
3. Symlinks the dotfiles into `$HOME`:
   - `~/.vimrc` → `vim/vimrc`, `~/.vim` → `vim/`
   - `~/.zshrc` → `zsh/zshrc`, `~/.p10k.zsh` → `zsh/p10k.zsh`, `~/.p9k.zsh` → `zsh/p9k.zsh`
   - `~/.bashrc` → `bash/bashrc` (replaces any existing file; back it up first if you care)
   - `~/.gitconfig` → `git/gitconfig`, `~/.gitconfig.local` → `git/gitconfig.local`, `~/.gitignore_global` → `git/gitignore_global`
   - `~/.fonts` → `fonts/`
   - `~/.config/Code/User/settings.json` → `vscode/settings.json`, `keybindings.json` likewise
4. Verifies vendored Meslo fonts and refreshes `fc-cache`.
5. Reconciles vendored VSIX with `code --list-extensions` and only re-installs extensions whose pinned version differs.

Knobs:

| Env var                    | Effect |
|----------------------------|--------|
| `DRY_RUN=1`                | print actions, do not modify the filesystem |
| `SKIP_MESLO_FONTS=1`       | skip the font-presence check + `fc-cache` step |
| `SKIP_VSCODE_EXTENSIONS=1` | skip the VS Code extension step |
| `VSCODE_CLI=/path/to/code` | override VS Code CLI auto-detect |

`~/.bashrc` and `~/.gitconfig.local` are linked with `force` semantics: existing **non-symlink** files at those paths are removed without backup. Back them up first if you care.

### Updating an air-gapped host (sneakernet)

Air-gapped boxes can't `git pull`. Since the repo is plain files (no submodules), packaging is just `tar`:

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

| File / directory                  | In git? | Purpose |
|-----------------------------------|---------|---------|
| **`git/gitconfig.local.example`** | yes     | Template for Git `user.*` |
| **`git/gitconfig.local`**         | **no**  | Real identity; created from the template on first install |
| **`local/env.zsh.example`**       | yes     | Template for shell env |
| **`local/env.zsh`**               | **no**  | Proxy, `PATH`, secrets, etc.; sourced at end of `zsh/zshrc` |
| **`fonts/MesloLGS NF *.ttf`**     | yes     | Vendored Meslo + `MesloLGS NF License.txt` (Apache 2.0) |

Never commit **`git/gitconfig.local`** or **`local/env.zsh`**.

### Vim plugins

Plugins live as plain directories under `vim/plugins-vendor/<name>/` and are loaded by **vim-plug** via local paths in `vim/vimrc`:

```vim
Plug '~/.vim/plugins-vendor/nerdtree'
" ...
```

`plug#end()` puts each one on `&runtimepath` at startup, so **no `PlugInstall` is needed**.

> **Air-gapped note**: `vim-easycomplete` ships per-language installer scripts under `vim/plugins-vendor/vim-easycomplete/autoload/easycomplete/installer/*.sh` that download LSP servers (rust-analyzer, jdtls, omnisharp, …) via `curl`. Don't run `:InstallLspServer` on offline hosts; pre-stage the servers manually or skip those completion features.

### Prompt theme: P10k with P9K fallback for old zsh

Powerlevel10k requires `zsh >= 5.1`. If `$ZSH_VERSION` is older (e.g. **5.0.2** on stock RHEL/CentOS 7 where you can't upgrade zsh), `zsh/zshrc` automatically falls back to its predecessor **Powerlevel9k**:

- `zsh/vendor/powerlevel10k/` — used on zsh ≥ 5.1, configured via `zsh/p10k.zsh` (linked as `~/.p10k.zsh`).
- `zsh/vendor/powerlevel9k/`  — used on zsh < 5.1, configured via `zsh/p9k.zsh` (linked as `~/.p9k.zsh`); rainbow-style preset roughly matching the P10k preset.

Both presets expect MesloLGS NF (vendored under `fonts/`). The Powerlevel10k instant-prompt cache block in `zsh/zshrc` is also gated on zsh ≥ 5.1, so the "minimum required version is 5.1" warning will not appear on older hosts.

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

## References

- [vim-plug](https://github.com/junegunn/vim-plug/wiki)
- [Powerlevel10k fonts](https://github.com/romkatv/powerlevel10k#fonts)
- [Powerlevel9k stylizing](https://github.com/Powerlevel9k/powerlevel9k/wiki/Stylizing-Your-Prompt)
