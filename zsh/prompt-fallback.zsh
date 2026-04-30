# Hand-crafted prompt for zsh < 5.1 (vendored Powerlevel9k is fragile there:
# its icons.zsh uses $'\uXXXX'/$'\UXXXXXXXX' everywhere, which are validated
# against LC_CTYPE at parse time on zsh 5.0.x — and the in-file `local LC_CTYPE`
# trick doesn't actually take effect that early. Result: icons array empty,
# separators/colors gone, prompt looks blank.)
#
# This file provides a small, reliable rainbow-ish prompt using only zsh builtins.
# UTF-8 chars (❯) are stored as raw bytes inside single-quoted strings, so they
# render fine even when LC_CTYPE is C/POSIX (the terminal does the rendering).

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr   '%F{yellow}+'
zstyle ':vcs_info:git:*' unstagedstr '%F{red}*'
zstyle ':vcs_info:git:*' formats       ' %F{magenta}(%b%c%u%F{magenta})%f'
zstyle ':vcs_info:git:*' actionformats ' %F{red}(%b|%a%c%u%F{red})%f'

dotfiles_precmd_vcs() { vcs_info }
typeset -ga precmd_functions
[[ -z "${precmd_functions[(r)dotfiles_precmd_vcs]}" ]] && precmd_functions+=(dotfiles_precmd_vcs)

setopt prompt_subst

# Two-line prompt:
#   line 1: user@host  cwd  (git-branch±)   [optional rprompt: exit code + clock]
#   line 2: ❯  (green when last cmd ok, red on error)
PROMPT='%F{blue}%n@%m%f %F{cyan}%~%f${vcs_info_msg_0_}
%(?.%F{green}.%F{red})❯%f '
RPROMPT='%(?..%F{red}[%?]%f) %F{8}%D{%H:%M:%S}%f'
