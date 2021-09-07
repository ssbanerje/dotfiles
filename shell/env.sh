#!/usr/bin/env bash

# Setup less
[[ -x /usr/bin/lesspipe ]] && eval "$(/usr/bin/lesspipe)"
if type less &> /dev/null; then
  export PAGER="less"
  export LESS="--ignore-case --LONG-PROMPT --QUIET --chop-long-lines -Sm --RAW-CONTROL-CHARS --quit-if-one-screen --no-init"
fi

# Setup GPG
export GPG_TTY="$TTY"

# Vim all the way
export VISUAL="nvim"
export EDITOR="nvim"
export USE_EDITOR="nvim"
export SVN_EDITOR="nvim"

# Binaries from dotfiles
if [[ ! "$PATH" == *"$HOME/.bin"* ]]; then
  export PATH="${PATH:+${PATH}:}$HOME/.bin"
fi

# Python startup settings
export PYTHONSTARTUP="$HOME/.pythonrc.py"

# Source Rustup
if [[ -d "$HOME/.cargo/" ]]; then
  source "$HOME/.cargo/env"
  if [[ ! "$PATH" == *"$HOME/.cargo/bin"* ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
  fi
fi

# Platform specific
source "$HOME/.config/env.$(uname -s).sh"

# Setup NPM binaries (Needs to come after the homebrew is loaded)
YARN_PATH="$(yarn global bin)"
if [[ ! "$PATH" == *"$YARN_PATH"* ]]; then
  export PATH="$YARN_PATH:${PATH}"
fi
unset YARN_PATH

# Load aliases
source "$HOME/.config/aliases.sh"
