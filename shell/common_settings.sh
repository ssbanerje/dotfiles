# Set less options
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
if [[ -x $(which less) ]]
then
  export PAGER="less"
  export LESS="--ignore-case --LONG-PROMPT --QUIET --chop-long-lines -Sm --RAW-CONTROL-CHARS --quit-if-one-screen --no-init"
fi

# Color scheme for terminal
export TERM="xterm-256color"

# Colourful man pages
export LESS_TERMCAP_mb="$(printf '\e[1;31m')"
export LESS_TERMCAP_md="$(printf '\e[1;31m')"
export LESS_TERMCAP_me="$(printf '\e[0m')"
export LESS_TERMCAP_se="$(printf '\e[0m')"
export LESS_TERMCAP_so="$(printf '\e[1;44;33m')"
export LESS_TERMCAP_ue="$(printf '\e[0m')"
export LESS_TERMCAP_us="$(printf '\e[1;32m')"

# Setup fasd
eval "$(fasd --init auto)"

# Source env
source "$HOME/.config/env.sh"
source "$HOME/.config/fzf.sh"
source "$HOME/.config/aliases.sh"

# Source color schemes
BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"
source ${HOME}/.config/base16-shell/scripts/base16-material.sh

# Source platform specific
source "$HOME/.config/common_settings.$(uname -s).sh"
