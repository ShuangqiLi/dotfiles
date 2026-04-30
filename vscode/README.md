# VS Code (dotfiles)

Target editor version: **`target-version.txt`** (currently **1.85.2**).  
On Linux, settings are symlinked to **`~/.config/Code/User/`**.

| Path | Purpose |
|------|---------|
| `settings.json` | User settings (JSONC) |
| `keybindings.json` | Keybindings (JSON array) |
| `extensions.txt` | Pinned `publisher.extension@version` lines (order = install order) |
| **`vsix/*.vsix`** | **Offline** extension packages (see below) |

## Offline install (no network on target)

1. On a **connected** machine (same **OS/CPU** as targets when extensions are platform-specific, e.g. **`linux-x64`**):

   ```bash
   bash scripts/fetch-vscode-vsix.sh
   git add vscode/vsix/*.vsix
   git commit -m "chore(vscode): vendor VSIX for offline install"
   ```

   Override platform: `TARGETPLATFORM=linux-arm64 bash scripts/fetch-vscode-vsix.sh`  
   Omit platform query (universal packages only): `TARGETPLATFORM= bash scripts/fetch-vscode-vsix.sh`

2. Copy the **whole repo** (including `vscode/vsix/`) to the air-gapped host and run **`./install`**.

3. Install logic: if **`vscode/vsix/*.vsix`** exists, extensions are installed **only** from those files, in **`extensions.txt`** order. No Marketplace access is used.

4. Strict mode (fail if any pinned extension is missing a `.vsix`):

   ```bash
   VSCODE_OFFLINE_ONLY=1 ./install
   ```

5. Filenames must match: **`vsix/{id}-{version}.vsix`** (the fetch script creates this layout).

See **`vsix/README.md`** for license / compliance notes.

## Online install (no vendored VSIX)

If **`vscode/vsix/`** has **no** `.vsix` files, `./install` falls back to **`code --install-extension id@version`** using **`extensions.txt`** (needs network).

## Other env vars

| Variable | Effect |
|----------|--------|
| `SKIP_VSCODE_EXTENSIONS=1` | Skip extension step entirely |
| `VSCODE_CLI=/path/to/code` | VS Code CLI binary |
| `VSCODE_OFFLINE_ONLY=1` | Require VSIX for every pin; error if `vsix/` empty or incomplete |

## Refresh extension pins

```bash
code --list-extensions --show-versions > /tmp/ext.txt
# merge lines into vscode/extensions.txt, then re-run fetch-vscode-vsix.sh and commit new VSIX
```

## Windows / macOS paths

This repo links **`~/.config/Code/User/`** (Linux). Native Windows uses `%APPDATA%\Code\User\`. **WSL** + Linux VS Code uses the Linux paths above.

## Cursor

Cursor uses **`~/.config/Cursor/User`**. Copy or symlink these JSON files there if you want the same config (not automated here).
