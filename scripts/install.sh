#!/usr/bin/env bash
# Self-contained installer (dotbot replacement). Symlinks files into $HOME and
# runs post-link hooks. Idempotent: a clean re-run does no work and exits ~0
# in a few seconds.
#
# Knobs:
#   DRY_RUN=1               print actions, do not modify the filesystem
#   SKIP_MESLO_FONTS=1      skip the font-presence check + fc-cache step
#   SKIP_VSCODE_EXTENSIONS=1 skip vendored-VSIX install (read by sub-script)
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DOTFILES"

DRY_RUN="${DRY_RUN:-}"

c_ok=$'\033[32m'
c_warn=$'\033[33m'
c_err=$'\033[31m'
c_dim=$'\033[2m'
c_off=$'\033[0m'
[[ -t 1 ]] || { c_ok=""; c_warn=""; c_err=""; c_dim=""; c_off=""; }

log()   { printf '%s\n' "$*"; }
info()  { printf '%s%s%s\n' "$c_dim" "$*" "$c_off"; }
ok()    { printf '%sok%s    %s\n' "$c_ok" "$c_off" "$*"; }
warn()  { printf '%swarn%s  %s\n' "$c_warn" "$c_off" "$*" >&2; }
err()   { printf '%serr%s   %s\n' "$c_err" "$c_off" "$*" >&2; }
run()   { if [[ -n "$DRY_RUN" ]]; then printf '%s+ %s%s\n' "$c_dim" "$*" "$c_off"; else "$@"; fi; }

# --- Step 1: ensure templated, gitignored files exist -----------------------
if [[ ! -f local/gitconfig.local ]]; then
  info "Creating local/gitconfig.local from template"
  run cp local/gitconfig.local.example local/gitconfig.local
fi

# --- Step 2: clean broken symlinks at the top level of $HOME ---------------
shopt -s dotglob nullglob
for f in "$HOME"/.[!.]*; do
  if [[ -L "$f" && ! -e "$f" ]]; then
    info "Removing broken symlink: $f"
    run rm -f "$f"
  fi
done
shopt -u dotglob nullglob

# --- Step 3: link config files into $HOME ----------------------------------
# Usage: link <source-relative-to-$DOTFILES> <target-absolute> [force]
#   force: if target exists and is NOT already the desired symlink, replace
#          it (no automatic backup; back up by hand if you care).
link() {
  local src="$1" dst="$2" flags="${3:-}"
  local abs="$DOTFILES/$src"
  if [[ ! -e "$abs" ]]; then
    err "missing source: $src"
    return 1
  fi
  run mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" ]]; then
    if [[ "$(readlink "$dst")" == "$abs" ]]; then
      ok "$dst"
      return 0
    fi
    run rm -f "$dst"
  elif [[ -e "$dst" ]]; then
    if [[ "$flags" == *force* ]]; then
      warn "replacing existing $dst (force)"
      run rm -rf "$dst"
    else
      err "exists and not a symlink: $dst (use 'force' or remove it manually)"
      return 1
    fi
  fi
  run ln -s "$abs" "$dst"
  ok "$dst -> $abs"
}

link vim/vimrc                "$HOME/.vimrc"
link vim                      "$HOME/.vim"
link zsh/zshrc                "$HOME/.zshrc"
link bash/bashrc              "$HOME/.bashrc"                              force
link zsh/p10k.zsh             "$HOME/.p10k.zsh"
link zsh/p9k.zsh              "$HOME/.p9k.zsh"
link git/gitconfig            "$HOME/.gitconfig"
link local/gitconfig.local    "$HOME/.gitconfig.local"                     force
link git/gitignore_global     "$HOME/.gitignore_global"
link fonts                    "$HOME/.fonts"
link vscode/settings.json     "$HOME/.config/Code/User/settings.json"
link vscode/keybindings.json  "$HOME/.config/Code/User/keybindings.json"

# --- Step 4: post-link hooks -----------------------------------------------
info "Clearing Powerlevel10k instant-prompt cache"
run rm -f "${XDG_CACHE_HOME:-$HOME/.cache}"/p10k-instant-prompt-*.zsh

info "Creating Vim cache directories"
run mkdir -p "$HOME/.cache/vim/swap" "$HOME/.cache/vim/backup" "$HOME/.cache/vim/undo" "$HOME/.cache/vim/plugged"

if [[ -n "${SKIP_MESLO_FONTS:-}" ]]; then
  info "SKIP_MESLO_FONTS=1: skipping Meslo font check"
else
  info "Verifying MesloLGS NF fonts (vendored under fonts/)"
  run bash "$DOTFILES/scripts/install-meslo-fonts.sh"
fi

info "Refreshing font cache (skips if up-to-date)"
run fc-cache "$HOME/.fonts"

info "Installing pinned VS Code extensions"
run bash "$DOTFILES/scripts/install-vscode-extensions.sh"

echo
ok "All tasks completed."
