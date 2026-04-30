# VS Code (dotfiles)

**Target version: `1.85.2`** (see `target-version.txt` — use the [1.85.2](https://code.visualstudio.com/updates) build on the air-gapped host).  
On Linux, settings are symlinked to **`~/.config/Code/User/`**.

| Path | Purpose |
|------|---------|
| `settings.json` | User settings (JSONC) |
| `keybindings.json` | Keybindings (JSON array) |
| `extensions.txt` | Pinned `publisher.extension@version` (install order) |
| **`vsix/*.vsix`** | Vendored extensions (**required** — see `EXTENSIONS.md`) |

## Offline install

The repo includes **`vscode/vsix/*.vsix`** aligned with **`extensions.txt`**. `./install` runs **`scripts/install-vscode-extensions.sh`**, which installs **only** from those files (no Marketplace).

Refreshing pins or VSIX must be done **outside** this repo’s scripts (e.g. download from [Open VSX](https://open-vsx.org) or the Visual Studio Marketplace). Document provenance in **`EXTENSIONS.md`**.

## Env vars

| Variable | Effect |
|----------|--------|
| `SKIP_VSCODE_EXTENSIONS=1` | Skip extension step |
| `VSCODE_CLI=/path/to/code` | VS Code CLI |

## Windows / macOS paths

This repo links **`~/.config/Code/User/`** (Linux). Native Windows uses `%APPDATA%\Code\User\`. **WSL** + Linux VS Code uses the Linux paths above.

## Cursor

Cursor uses **`~/.config/Cursor/User`**. Copy or symlink these JSON files there if you want the same config (not automated here).
