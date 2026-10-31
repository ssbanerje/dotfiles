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
fi
# }}}

# For Linux {{{
if [[ "$UNAME" == "Linux" ]]; then
  alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history | tail -n1 | sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
fi
# }}}

# vim:foldmethod=marker
