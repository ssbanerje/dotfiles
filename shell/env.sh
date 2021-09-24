#!/usr/bin/env bash

# Setup environment variables {{{

# Set locale
if [[ "${UNAME:=$(uname -s)}" == 'Darwin' ]]; then
  export LANG='en_US.UTF-8'
  export LANGUAGE='en_US:en'
  export LC_CTYPE='UTF-8'
  export LC_NUMERIC='en_US.UTF-8'
  export LC_TIME='en_US.UTF-8'
  export LC_COLLATE='en_US.UTF-8'
  export LC_MONETARY='en_US.UTF-8'
  export LC_MESSAGES='en_US.UTF-8'
  export LC_PAPER='en_US.UTF-8'
  export LC_NAME='en_US.UTF-8'
  export LC_ADDRESS='en_US.UTF-8'
  export LC_TELEPHONE='en_US.UTF-8'
  export LC_ALL='en_US.UTF-8'
  export LC_MEASUREMENT='en_US.UTF-8'
  export LC_IDENTIFICATION='en_US.TF-8'
fi

# Setup less
[[ -x /usr/bin/lesspipe ]] && eval "$(/usr/bin/lesspipe)"
if type less &> /dev/null; then
  export PAGER="less"
  export LESS="--ignore-case --LONG-PROMPT --QUIET --chop-long-lines -Sm --RAW-CONTROL-CHARS --quit-if-one-screen --no-init"
fi

# Setup GPG
export GPG_TTY="$TTY"

# Vim all the way
export VISUAL="lvim"
export EDITOR="lvim"
export USE_EDITOR="lvim"
export SVN_EDITOR="lvim"

# }}}

# Setup PATH {{{

# Helper Functions {{{
function PREPEND_PATH() {
  while [[ "$#" -ne 0 ]]; do
    if [[ "$PATH" != *:$1:* ]]; then
      export PATH="$1:$PATH"
    fi
    shift
  done
}

function APPEND_PATH() {
  while [[ "$#" -ne 0 ]]; do
    if [[ "$PATH" != *:$1:* ]]; then
      export PATH="$PATH:$1"
    fi
    shift
  done
}
# }}}

if [[ -x /usr/libexec/path_helper ]]; then
  eval "$(/usr/libexec/path_helper -s)"
fi

if [[ "${UNAME:=$(uname -s)}" == 'Linux' ]]; then
  APPEND_PATH \
    /sbin \
    /usr/sbin \
    /usr/local/sbin \
    "$([[ -d /usr/local/cuda ]] && echo /usr/local/cuda/bin)"
elif [[ "${UNAME:=$(uname -s)}" == 'Darwin' ]]; then
  PREPEND_PATH \
    /usr/local/bin \
    /usr/local/sbin \
    /usr/local/opt/llvm/bin \
    /usr/local/opt/python/libexec/bin
fi

PREPEND_PATH \
  "$HOME/.local/bin" \
  "$HOME/.cargo/bin"

unset PREPEND_PATH
unset APPEND_PATH

# }}}

# vim:foldmethod=marker
