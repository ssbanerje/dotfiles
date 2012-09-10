######################################################################
# .zshrc file for my mac
# Author: Subho Sankar Banerjee
# EMail: subs.zero[at]gmail[dot]com
########################################################################


# Skip all this for non-interactive shells
[[ -z "$PS1" ]] && return

# Fancier prompt
#PS1=$'%F{def}%(?..%B%K{red}[%?]%K{def}%b )%(1j.%b%K{yel}%F{bla}%jJ%F{def}%K{def} .)%F{white}%B%*%b %F{m}%n@%m:%F{white}%~ %(!.#.>) %F{def}'

# Set less options
if [[ -x $(which less) ]]
then
    export PAGER="less"
    export LESS="--ignore-case --LONG-PROMPT --QUIET --chop-long-lines -Sm --RAW-CONTROL-CHARS --quit-if-one-screen --no-init"
fi

# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh

# Set to the name theme to load.
export ZSH_THEME="miloshadzic"

# Comment this out to disable weekly auto-update checks
export DISABLE_AUTO_UPDATE="true"

# Plugins
plugins=(osx git git-flow github brew history-substring-search mercurial node npm perl pip python ssh-agent sublime svn terminalapp textmate vi-mode zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Get stuff from .profile
source $HOME/.profile

# Get completion for homebrew
fpath=($HOME/.zsh/func $fpath)
typeset -U fpath

