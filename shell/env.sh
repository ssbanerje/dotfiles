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

# }}}

# Setup PATH {{{

function _add_path() {
  local mode="$1" dir
  shift
  for dir in "$@"; do
    [[ -n "$dir" && -d "$dir" ]] || continue
    case ":$PATH:" in
      *":$dir:"*) ;;
      *)
        if [[ "$mode" == "prepend" ]]; then
          export PATH="$dir${PATH:+:$PATH}"
        else
          export PATH="${PATH:+$PATH:}$dir"
        fi
        ;;
    esac
  done
}

function PREPEND_PATH() { _add_path prepend "$@"; }
function APPEND_PATH()  { _add_path append "$@"; }

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
_fd_bin=""
if command -v fd >/dev/null 2>&1; then
  _fd_bin="fd"
elif command -v fdfind >/dev/null 2>&1; then
  _fd_bin="fdfind"
fi
if [[ -n "$_fd_bin" ]]; then
  export FZF_DEFAULT_COMMAND="${_fd_bin} --type f --strip-cwd-prefix --hidden --follow --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="${_fd_bin} --type d --strip-cwd-prefix --hidden --follow --exclude .git"
fi
unset _fd_bin
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border --info=inline"

# Machine-local environment overrides (untracked; can call PREPEND_PATH / APPEND_PATH)
if [[ -r "$HOME/.config/env.local.sh" ]]; then
  source "$HOME/.config/env.local.sh"
fi

unset -f _add_path PREPEND_PATH APPEND_PATH

# }}}

# vim:foldmethod=marker
