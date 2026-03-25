# `local/` — per-machine only

Files here are **not** committed (see root `.gitignore`). The repo only ships **`env.zsh.example`**.

1. `cp env.zsh.example env.zsh`
2. Edit `env.zsh` for proxies, extra `PATH`, secrets, `DISPLAY`, etc.
3. Open a new zsh — `zshrc` sources `local/env.zsh` when present.

Git identity lives in **`gitconfig.local`** (repo root, also gitignored); use **`gitconfig.local.example`** as the template.
