# Interactive bash only (skip for scp, scripts, etc.)
[[ $- == *i* ]] || return 0

# Hand off to zsh when it exists. Path is not always /usr/bin/zsh (e.g. RHEL often uses /bin/zsh).
_dotfiles_zsh=
if [[ -x /usr/bin/zsh ]]; then
  _dotfiles_zsh=/usr/bin/zsh
elif [[ -x /bin/zsh ]]; then
  _dotfiles_zsh=/bin/zsh
else
  _dotfiles_zsh=$(command -v zsh 2>/dev/null) || true
  [[ -n "$_dotfiles_zsh" && -x "$_dotfiles_zsh" ]] || _dotfiles_zsh=
fi

if [[ -n "$_dotfiles_zsh" && -n "${BASH_VERSION:-}" ]]; then
  # Windows: never exec zsh from bash — that would drop the user back in
  # conhost/cmd; Git Bash is the intended terminal. Also skip the exec when a
  # Windows terminal is active (MSYSTEM/OSTYPE set, e.g. inside a script).
  case "${OSTYPE:-}:${MSYSTEM:-}" in
    msys*|cygwin*|*:MINGW*|*:MSYS*|*:CYGWIN*) ;;
    *)
      export SHELL="$_dotfiles_zsh"
      exec "$_dotfiles_zsh"
      ;;
  esac
fi
unset _dotfiles_zsh

# Rarely reached (the exec above handles normal cases): bash-only session.
# Resolve the dotfiles root from this file's real path.
_DOTFILES="${BASH_SOURCE[0]}"
while [[ -L "$_DOTFILES" ]]; do
  _d="$(cd "$(dirname "$_DOTFILES")" && pwd)"
  _DOTFILES="$(readlink "$_DOTFILES")"
  [[ "$_DOTFILES" = /* ]] || _DOTFILES="$_d/$_DOTFILES"
done
export DOTFILES="$(dirname "$(dirname "$_DOTFILES")")"
unset _d

[[ -f "$DOTFILES/zsh/aliases" ]] && source "$DOTFILES/zsh/aliases"

# Machine-specific env (not in git)
[[ -f "$DOTFILES/local/zshrc.local" ]] && source "$DOTFILES/local/zshrc.local"
