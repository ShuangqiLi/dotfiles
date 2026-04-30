# Powerlevel9k configuration for zsh 5.0.2 hosts where Powerlevel10k can't run
# (P10k requires zsh >= 5.1). Variables MUST be defined before
# `powerlevel9k.zsh-theme` is sourced — zshrc handles that ordering.
#
# Aim for a rainbow/powerline look similar to the p10k preset committed in
# ~/.p10k.zsh, while only using POWERLEVEL9K_* knobs that the original P9K
# theme actually understands. Anything more advanced (per-class dir colors,
# custom expansions, transient prompts, instant prompt, …) is P10k-only and
# is intentionally omitted here.

# Use Nerd Font glyphs (we ship MesloLGS NF under fonts/). Switch to
# 'awesome-fontconfig' if your terminal only has the older Awesome font.
typeset -g POWERLEVEL9K_MODE='nerdfont-complete'

# Two-line prompt: segments above, command line below.
typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
typeset -g POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

# Powerline separators (filled triangle / sharp head).
typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=$'\uE0B0'   # 
typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=$'\uE0B2'  # 
typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=$'\uE0B1'
typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=$'\uE0B3'

typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='%K{black}%F{black} '
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{cyan}\u276F%f '   # ❯

# Segment lists (mirror the p10k preset, restricted to segments P9K supports).
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  dir
  vcs
)

typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
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
typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=3
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY='truncate_middle'
typeset -g POWERLEVEL9K_DIR_HOME_BACKGROUND='blue'
typeset -g POWERLEVEL9K_DIR_HOME_FOREGROUND='black'
typeset -g POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='blue'
typeset -g POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='black'
typeset -g POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='blue'
typeset -g POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='black'
typeset -g POWERLEVEL9K_DIR_ETC_BACKGROUND='blue'
typeset -g POWERLEVEL9K_DIR_ETC_FOREGROUND='black'

# VCS: green=clean, yellow=dirty, red=hard-conflict.
typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND='green'
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='black'
typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='yellow'
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='black'
typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='yellow'
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='black'
typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND='grey'
typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND='black'
typeset -g POWERLEVEL9K_SHOW_CHANGESET=true
typeset -g POWERLEVEL9K_CHANGESET_HASH_LENGTH=8

# Right side: subtle dark background, color the symbols only.
typeset -g POWERLEVEL9K_STATUS_OK=false
typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND='black'
typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND='green'
typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND='black'
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND='red'

typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND='black'
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='cyan'

typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND='black'
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND='cyan'

typeset -g POWERLEVEL9K_VIRTUALENV_BACKGROUND='black'
typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND='magenta'
typeset -g POWERLEVEL9K_ANACONDA_BACKGROUND='black'
typeset -g POWERLEVEL9K_ANACONDA_FOREGROUND='magenta'
typeset -g POWERLEVEL9K_PYENV_BACKGROUND='black'
typeset -g POWERLEVEL9K_PYENV_FOREGROUND='magenta'
typeset -g POWERLEVEL9K_NVM_BACKGROUND='black'
typeset -g POWERLEVEL9K_NVM_FOREGROUND='green'

typeset -g POWERLEVEL9K_KUBECONTEXT_BACKGROUND='black'
typeset -g POWERLEVEL9K_KUBECONTEXT_FOREGROUND='magenta'
typeset -g POWERLEVEL9K_AWS_BACKGROUND='black'
typeset -g POWERLEVEL9K_AWS_FOREGROUND='208'
typeset -g POWERLEVEL9K_TERRAFORM_BACKGROUND='black'
typeset -g POWERLEVEL9K_TERRAFORM_FOREGROUND='208'

typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
typeset -g POWERLEVEL9K_TIME_BACKGROUND='black'
typeset -g POWERLEVEL9K_TIME_FOREGROUND='245'
