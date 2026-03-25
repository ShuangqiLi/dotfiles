# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH=$HOME/.local/bin:/usr/local/bin:$PATH

# Oh My Zsh library (via antidote) reads this before plugins load.
DISABLE_AUTO_TITLE="true"

######################################################################
# antidote — https://antidote.sh
######################################################################
if [[ -r ~/.antidote/antidote.zsh && -r ~/.zsh_plugins.txt ]]; then
  source ~/.antidote/antidote.zsh
  antidote load ~/.zsh_plugins.txt
fi

bindkey '^ ' autosuggest-accept
bindkey '^\n' autosuggest-execute

######################################################################
# User configuration
######################################################################
export TERM="xterm-256color"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg-yellow'

# Local X11 default only when not using SSH, Wayland, or an existing DISPLAY.
if [[ -z "$SSH_CONNECTION" && -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" && "$OSTYPE" == linux-* ]]; then
  export DISPLAY=:0.0
fi

######################################################################
# alias
######################################################################
if ls --color=auto / >/dev/null 2>&1; then
  alias ls='ls --color=auto'
  alias ll='ls -l --color=auto'
  alias la='ls -A --color=auto'
elif [[ "$OSTYPE" == darwin* ]]; then
  alias ls='ls -G'
  alias ll='ls -lG'
  alias la='ls -AG'
else
  alias ll='ls -l'
  alias la='ls -A'
fi

alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias gs='git status'
alias gc='git checkout'
alias gd='git diff -w'
alias gl='git log'
alias gb='git branch'
alias gp='git pull'
alias gf='git fetch'
alias gsu='git submodule update --recursive --init'
alias rg='rg --no-heading'

fg() {
  if [[ $# -eq 1 && $1 = - ]]; then
    builtin fg %-
  else
    builtin fg %"$@"
  fi
}

alias Ctags='ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extras=+q --language-force=C++'

Cscope() {
  find $(pwd) -type f -name "*.hpp" -o -name "*.cpp" -o -name "*.h" -o -name "*.c" -o -name "*.hh" -o -name "*.cc" > cscope.files
  cscope -bR
}

alias go='cd `git rev-parse --show-toplevel`'

######################################################################
# fzf
######################################################################
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Optional preview tools: rougify, highlight, coderay (install separately for rich previews).
alias fls='fzf --preview '"'"'[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (rougify {} || highlight -O ansi -l {} || coderay {} || cat {}) 2> /dev/null | head -500'"'"

fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

cf() {
  if ! command -v locate >/dev/null 2>&1; then
    echo "cf: locate not found; install plocate/mlocate and refresh the DB (e.g. updatedb)" >&2
    return 1
  fi
  local file
  file="$(locate -Ai -0 $@ | grep -z -vE '~$' | fzf --read0 -0 -1)"
  if [[ -n $file ]]; then
    if [[ -d $file ]]; then
      cd -- $file
    else
      cd -- ${file:h}
    fi
  fi
}

# Machine-specific env (not in git): see local/env.zsh.example
_dotfiles_dir="${0:A:h}"
[[ -f "$_dotfiles_dir/local/env.zsh" ]] && source "$_dotfiles_dir/local/env.zsh"
unset _dotfiles_dir
