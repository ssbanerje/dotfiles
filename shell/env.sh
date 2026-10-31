#!/usr/bin/env bash

# Setup environment variables {{{

UNAME="${UNAME:-$(uname -s)}"

# Set locale & macOS platform defaults
if [[ "$UNAME" == "Darwin" ]]; then
  export LANG='en_US.UTF-8'
  export LANGUAGE='en_US:en'
  export LC_ALL='en_US.UTF-8'
  export BASH_SILENCE_DEPRECATION_WARNING="1"

  if [[ -z "${BREW_PREFIX:-}" ]]; then
    if [[ -d /opt/homebrew ]]; then
      export BREW_PREFIX="/opt/homebrew"
    elif [[ -d /usr/local/Homebrew || -x /usr/local/bin/brew ]]; then
      export BREW_PREFIX="/usr/local"
    fi
  fi
fi

# Standard XDG base directories
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Encoding, GPG TTY, and CLI telemetry opt-outs
export PYTHONIOENCODING="UTF-8"
export DO_NOT_TRACK="1"
export HOMEBREW_NO_ANALYTICS="1"
if [[ -t 0 ]]; then
  export GPG_TTY
  GPG_TTY="$(tty)"
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
  "$HOME/.cargo/bin"

# fzf defaults (after PATH setup so Homebrew / ~/.local/bin fd is visible)
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --follow --exclude .git'
elif command -v fdfind >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fdfind --type f --strip-cwd-prefix --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fdfind --type d --strip-cwd-prefix --hidden --follow --exclude .git'
fi
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border --info=inline"

# Machine-local environment overrides (untracked; can call PREPEND_PATH / APPEND_PATH)
[[ -r "$HOME/.config/env.local.sh" ]] && source "$HOME/.config/env.local.sh"

unset -f PREPEND_PATH APPEND_PATH

# }}}

# vim:foldmethod=marker
