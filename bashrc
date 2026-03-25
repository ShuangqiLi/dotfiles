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
  export SHELL="$_dotfiles_zsh"
  exec "$_dotfiles_zsh"
fi
unset _dotfiles_zsh
