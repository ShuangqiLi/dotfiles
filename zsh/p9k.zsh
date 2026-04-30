# Powerlevel9k configuration for zsh 5.0.2 hosts where Powerlevel10k can't run
# (P10k requires zsh >= 5.1). Variables MUST be defined before
# `powerlevel9k.zsh-theme` is sourced — zshrc handles that ordering.
#
# Do not use `typeset -g` here: on zsh 5.0.x it can trigger parse/runtime errors
# (e.g. "unknown file attribute") and leave POWERLEVEL9K_* arrays unset → empty
# prompt segments → `command not found: prompt_`. Top-level `source` makes plain
# assignments global anyway.
#
# Aim for a rainbow/powerline look similar to the p10k preset committed in
# ~/.p10k.zsh, while only using POWERLEVEL9K_* knobs that the original P9K
# theme actually understands. Anything more advanced (per-class dir colors,
# custom expansions, transient prompts, instant prompt, …) is P10k-only and
# is intentionally omitted here.

# Use Nerd Font glyphs (we ship MesloLGS NF under fonts/). Switch to
# 'awesome-fontconfig' if your terminal only has the older Awesome font.
POWERLEVEL9K_MODE='nerdfont-complete'

# Two-line prompt: segments above, command line below.
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

# Powerline separators (filled triangle / sharp head). Use raw UTF-8 byte
# sequences instead of $'\uXXXX' so this file parses cleanly even when
# LC_CTYPE is C/POSIX (zsh validates \uXXXX against the locale's wide-char
# range and otherwise emits "character not in range", leaving the string
# empty — which then breaks the rest of the array assignments below).
#   U+E0B0  
POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=$'\xee\x82\xb0'
#   U+E0B2  
POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=$'\xee\x82\xb2'
#   U+E0B1  
POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=$'\xee\x82\xb1'
#   U+E0B3  
POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=$'\xee\x82\xb3'

POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='%K{black}%F{black} '
#   U+276F ❯
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=$'%F{cyan}\xe2\x9d\xaf%f '

# Segment lists (mirror the p10k preset, restricted to segments P9K supports).
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  dir
  vcs
)

POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  status
  command_execution_time
  background_jobs
  virtualenv
  anaconda
  pyenv
  nvm
  kubecontext
  aws
  terraform
  time
)

# Directory: blue background, dark foreground, truncate middle to keep prompt short.
POWERLEVEL9K_SHORTEN_DIR_LENGTH=3
POWERLEVEL9K_SHORTEN_STRATEGY='truncate_middle'
POWERLEVEL9K_DIR_HOME_BACKGROUND='blue'
POWERLEVEL9K_DIR_HOME_FOREGROUND='black'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='blue'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='black'
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='blue'
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='black'
POWERLEVEL9K_DIR_ETC_BACKGROUND='blue'
POWERLEVEL9K_DIR_ETC_FOREGROUND='black'

# VCS: green=clean, yellow=dirty, red=hard-conflict.
POWERLEVEL9K_VCS_CLEAN_BACKGROUND='green'
POWERLEVEL9K_VCS_CLEAN_FOREGROUND='black'
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='yellow'
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='black'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='yellow'
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='black'
POWERLEVEL9K_VCS_LOADING_BACKGROUND='grey'
POWERLEVEL9K_VCS_LOADING_FOREGROUND='black'
POWERLEVEL9K_SHOW_CHANGESET=true
POWERLEVEL9K_CHANGESET_HASH_LENGTH=8

# Right side: subtle dark background, color the symbols only.
POWERLEVEL9K_STATUS_OK=false
POWERLEVEL9K_STATUS_OK_BACKGROUND='black'
POWERLEVEL9K_STATUS_OK_FOREGROUND='green'
POWERLEVEL9K_STATUS_ERROR_BACKGROUND='black'
POWERLEVEL9K_STATUS_ERROR_FOREGROUND='red'

POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND='black'
POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='cyan'

POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND='black'
POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND='cyan'

POWERLEVEL9K_VIRTUALENV_BACKGROUND='black'
POWERLEVEL9K_VIRTUALENV_FOREGROUND='magenta'
POWERLEVEL9K_ANACONDA_BACKGROUND='black'
POWERLEVEL9K_ANACONDA_FOREGROUND='magenta'
POWERLEVEL9K_PYENV_BACKGROUND='black'
POWERLEVEL9K_PYENV_FOREGROUND='magenta'
POWERLEVEL9K_NVM_BACKGROUND='black'
POWERLEVEL9K_NVM_FOREGROUND='green'

POWERLEVEL9K_KUBECONTEXT_BACKGROUND='black'
POWERLEVEL9K_KUBECONTEXT_FOREGROUND='magenta'
POWERLEVEL9K_AWS_BACKGROUND='black'
POWERLEVEL9K_AWS_FOREGROUND='208'
POWERLEVEL9K_TERRAFORM_BACKGROUND='black'
POWERLEVEL9K_TERRAFORM_FOREGROUND='208'

POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
POWERLEVEL9K_TIME_BACKGROUND='black'
POWERLEVEL9K_TIME_FOREGROUND='245'
