# `local/` — per-machine only

Files here are **not** committed (see root `.gitignore`). The repo only ships **`env.zsh.example`**.

1. `cp env.zsh.example env.zsh`
2. Edit `env.zsh` for proxies, extra `PATH`, secrets, `DISPLAY`, etc.
3. Open a new zsh — `zsh/zshrc` sources `local/env.zsh` when present (it picks the file up via `$DOTFILES/local/env.zsh`).

Git identity lives in **`git/gitconfig.local`** (also gitignored); use **`git/gitconfig.local.example`** as the template. `./install` creates `git/gitconfig.local` from the example on first run.
