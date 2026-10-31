#!/usr/bin/env bash

# Ask before overwriting
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# ls/grep variants for Bash (OMZ provides these in Zsh)
if [[ -n "${BASH_VERSION:-}" ]]; then
  if [[ "$UNAME" == "Darwin" ]]; then
    alias ls='command ls -G'
  else
    alias ls='command ls --color=auto'
  fi
  alias ll='ls -alF'
  alias la='ls -A'
  alias grep='command grep --color=auto'
fi

# Python
alias ipython='ipython --TerminalInteractiveShell.editing_mode=vi'

# Yazi wrapper that changes cwd on exit (unalias OMZ yarn plugin's `y=yarn` first)
unalias y 2>/dev/null || true
function y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  command yazi "$@" --cwd-file="$tmp"
  if IFS= read -r -d '' cwd < "$tmp" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd" || return
  fi
  rm -f -- "$tmp"
}

# Portable helper functions {{{

# Create a directory tree and enter it
function mkd() {
  mkdir -p -- "$@" && builtin cd -- "${@: -1}"
}

# Print each PATH entry on its own line
function path() {
  printf '%s\n' "${PATH//:/$'\n'}"
}

# Determine human-readable size of a file or directory
function fs() {
  local arg=-sh
  du -b /dev/null >/dev/null 2>&1 && arg=-sbh
  if (( $# )); then
    du "$arg" -- "$@"
  else
    (
      if [[ -n "${ZSH_VERSION:-}" ]]; then
        setopt localoptions nullglob
      else
        shopt -s nullglob
      fi
      set -- .[^.]* ./*
      if (( $# )); then
        du "$arg" -- "$@"
      else
        du "$arg" .
      fi
    )
  fi
}

# Start a local-only HTTP server in the current directory
function serve() {
  local port="${1:-8000}"
  python3 -m http.server --bind 127.0.0.1 "$port"
}

# Export key=value entries from a dotenv file into the current shell
function dotenv() {
  local env_file="${1:-.env}"
  if [[ ! -r "$env_file" ]]; then
    printf 'dotenv: cannot read %s\n' "$env_file" >&2
    return 1
  fi
  set -a
  # shellcheck disable=SC1090
  source "$env_file"
  set +a
}

# }}}

# Normalize `open` and clipboard on non-macOS {{{
if [[ "$UNAME" != "Darwin" ]]; then
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    alias open='open_command'
    alias pbcopy='clipcopy'
    alias pbpaste='clippaste'
  elif grep -qi microsoft /proc/version 2>/dev/null; then
    alias open='explorer.exe'
    alias pbcopy='clip.exe'
    alias pbpaste='powershell.exe -c Get-Clipboard'
  elif [[ -n "${WAYLAND_DISPLAY:-}" ]] && command -v wl-copy >/dev/null 2>&1; then
    alias open='xdg-open'
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste --no-newline'
  else
    alias open='xdg-open'
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
  fi
fi
# }}}

# For macOS {{{
if [[ "$UNAME" == "Darwin" ]]; then
  alias ssh='ssh -o "XAuthLocation=/opt/X11/bin/xauth"'
  alias preview='open -a Preview'
  alias xcode='open -a Xcode'
  alias plistbuddy='/usr/libexec/PlistBuddy'
  alias safari='open -a Safari'
  alias chrome='open -a "Google Chrome"'
  alias mute='osascript -e "set volume output muted true"'
  alias maxvol='osascript -e "set volume output volume 100"'
  alias restart_yabai='launchctl kickstart -k "gui/${UID}/homebrew.mxcl.yabai"'

  # cd into whatever directory the frontmost Finder window is showing
  function cdf() {
    local target
    target="$(osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)')"
    if [[ -n "$target" ]]; then
      builtin cd -- "$target" || return
    else
      printf 'No Finder window found\n' >&2
      return 1
    fi
  }
fi
# }}}

# For Linux {{{
if [[ "$UNAME" == "Linux" ]]; then
  alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history | tail -n1 | sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
fi
# }}}

# vim:foldmethod=marker
