#!/usr/bin/env bash

# Setup environment variables {{{

UNAME="${UNAME:-$(uname -s)}"

# Set locale on macOS
if [[ "$UNAME" == "Darwin" ]]; then
  export LANG='en_US.UTF-8'
  export LANGUAGE='en_US:en'
  export LC_ALL='en_US.UTF-8'

  if [[ -z "${BREW_PREFIX:-}" ]]; then
    if [[ -d /opt/homebrew ]]; then
      export BREW_PREFIX="/opt/homebrew"
    elif [[ -d /usr/local/Homebrew || -x /usr/local/bin/brew ]]; then
      export BREW_PREFIX="/usr/local"
    fi
  fi
fi

# Setup less
[[ -x /usr/bin/lesspipe ]] && eval "$(/usr/bin/lesspipe)"
if command -v less >/dev/null 2>&1; then
  export PAGER="less"
  export LESS="--ignore-case --LONG-PROMPT --QUIET --chop-long-lines -Sm --RAW-CONTROL-CHARS --quit-if-one-screen --no-init"
fi

# Default editor
export VISUAL="nvim"
export EDITOR="nvim"
export USE_EDITOR="nvim"
export SVN_EDITOR="nvim"

# fzf defaults
export FZF_DEFAULT_OPTS="--border"

# }}}

# Setup PATH {{{

function PREPEND_PATH() {
  local dir
  for dir in "$@"; do
    [[ -n "$dir" && -d "$dir" ]] || continue
    case ":$PATH:" in
      *":$dir:"*) ;;
      *) export PATH="$dir${PATH:+:$PATH}" ;;
    esac
  done
}

function APPEND_PATH() {
  local dir
  for dir in "$@"; do
    [[ -n "$dir" && -d "$dir" ]] || continue
    case ":$PATH:" in
      *":$dir:"*) ;;
      *) export PATH="${PATH:+$PATH:}$dir" ;;
    esac
  done
}

if [[ -x /usr/libexec/path_helper ]]; then
  eval "$(/usr/libexec/path_helper -s)"
fi

if [[ "$UNAME" == "Linux" ]]; then
  APPEND_PATH \
    /sbin \
    /usr/sbin \
    /usr/local/sbin \
    /usr/local/cuda/bin
elif [[ "$UNAME" == "Darwin" && -n "${BREW_PREFIX:-}" ]]; then
  PREPEND_PATH \
    "$BREW_PREFIX/bin" \
    "$BREW_PREFIX/sbin" \
    "$BREW_PREFIX/opt/llvm/bin" \
    "$BREW_PREFIX/opt/python/libexec/bin"
fi

PREPEND_PATH \
  "$HOME/.local/bin" \
  "$HOME/.cargo/bin" \
  "$HOME/.npm-global/bin"

unset -f PREPEND_PATH APPEND_PATH

# }}}

# vim:foldmethod=marker
