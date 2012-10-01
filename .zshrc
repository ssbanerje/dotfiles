######################################################################
# .zshrc file
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
#export ZSH_THEME="miloshadzic"
setopt prompt_subst
precmd() {
    PROMPT=$(~/.powerline-bash/powerline-bash.py $?)
}

# Comment this out to disable weekly auto-update checks
export DISABLE_AUTO_UPDATE="true"

# Plugins
plugins=(git git-flow github brew history-substring-search mercurial node npm perl pip python sublime svn terminalapp textmate zsh-syntax-highlighting)
if [[ `uname` = "Darwin" ]]; then 
  plugins=(osx $plugins)
fi
source $ZSH/oh-my-zsh.sh

# Get stuff from .profile
source $HOME/.profile
if [[ `uname` = "Darwin" ]]; then 
  source $HOME/.profile.osx
fi

setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS # allow functions to have local traps
setopt SHARE_HISTORY # share history between sessions
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt HIST_IGNORE_ALL_DUPS  # don't record dupes in history
setopt HIST_REDUCE_BLANKS
setopt complete_aliases

zle -N newtab

bindkey '^[^[[D' backward-word
bindkey '^[^[[C' forward-word
bindkey '^[[5D' beginning-of-line
bindkey '^[[5C' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[^N' newtab
bindkey '^?' backward-delete-char

