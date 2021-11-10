#!/usr/bin/env bash

# Ask before overwriting
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# ls variants
# This comes from OMZ in ZSH. This is for bash.
if [[ -n "$BASH" ]]; then
  [[ "${UNAME:=$(uname -s)}" == "Darwin" ]] && alias ls="ls -G"
  [[ "${UNAME:=$(uname -s)}" == "Linux" ]] && alias ls="ls --color=auto"
  alias ll="ls -alF"
  alias la="ls -A"
  alias grep="grep --color=auto"
fi

# Python
alias pipup="pip freeze --local | cut -d = -f 1  | xargs pip install -U"
alias pip3up="pip3 freeze --local | cut -d = -f 1  | xargs pip3 install -U"
alias ipython="ipython --TerminalInteractiveShell.editing_mode=vi"

# Normalize `open` and clipboard {{{
if [[ ! "${UNAME:=$(uname -s)}" == "Darwin" ]]; then
  if grep -q Microsoft /proc/version; then
    alias open="explorer.exe";
    alias pbcopy=" clip.exe"
    alias pbpaste="powershell.exe -c Get-Clipboard"
  else
    alias open="xdg-open";
    alias pbcopy="xsel --clipboard --input"
    alias pbpaste="xsel --clipboard --output"
  fi
fi
# }}}

# For MacOS {{{
if [[ "${UNAME:=$(uname -s)}" == "Darwin" ]]; then
  # SSH X forwarding
  alias ssh='ssh -o "XAuthLocation=/opt/X11/bin/xauth"'

  #Open apps
  alias preview="open -a Preview"
  alias xcode="open -a Xcode"
  alias plistbuddy="/usr/libexec/PlistBuddy"
  alias safari="open -a safari"
  alias chrome="open -a Google\ Chrome"

  # Control volume
  alias mute='osascript -e "set volume output muted true"'
  alias maxvol='osascript -e "set volume output volume 100"'

  # Yabai
  alias restart_yabai='launchctl kickstart -k "gui/${UID}/homebrew.mxcl.yabai"'
fi
#}}}

# For Linux {{{
if [[ "${UNAME:=$(uname -s)}" == "Linux" ]]; then
  # Setup alerts for long running commands
  alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history 1|sed '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
fi
#}}}

# vim:foldmethod=marker
