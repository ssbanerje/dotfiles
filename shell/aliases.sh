#!/usr/bin/env bash

function export_function() {
  if [[ -n "${ZSH_VERSION}" ]]; then
    zle -N "$1"  # zsh-specific, turn function into widget.
  else
    export -f "$1"  # Bash or others, use export -f hack.
  fi
}

# export_alias is like `alias`, but it exports to subshells.
function export_alias() {
  local ALIAS="${1}"
  shift
  eval "function ${ALIAS}() { ${@} \"\${@}\"; }"
  export_function "${ALIAS}"
}

# Ask before overwriting
export_alias rm 'rm -i'
export_alias mv 'mv -i'
export_alias cp 'cp -i'

# ls variants
# This comes from OMZ in ZSH. This is for bash.
if [[ -n "$BASH" ]]; then
  [[ "${UNAME: $(uname -s)}" == "Darwin" ]] && export_alias ls "ls -G"
  [[ "${UNAME: $(uname -s)}" == "Linux" ]] && export_alias ls "ls --color=auto"
  export_alias ll "ls -alF"
  export_alias la "ls -A"
  export_alias grep "grep --color=auto"
fi

# Python
export_alias pipup "pip freeze --local | cut -d = -f 1  | xargs pip install -U"
export_alias pip3up "pip3 freeze --local | cut -d = -f 1  | xargs pip3 install -U"
export_alias ipython "ipython --TerminalInteractiveShell.editing_mode=vi"

# Normalize `open` and clipboard {{{
if [[ ! "${UNAME:=$(uname -s)}" == "Darwin" ]]; then
  if grep -q Microsoft /proc/version; then
    export_alias open "explorer.exe";
    export_alias pbcopy " clip.exe"
    export_alias pbpaste "powershell.exe -c Get-Clipboard"
  else
    export_alias open "xdg-open";
    export_alias pbcopy "xsel --clipboard --input"
    export_alias pbpaste "xsel --clipboard --output"
  fi
fi
# }}}

# For MacOS {{{
if [[ "${UNAME:=$(uname -s)}" == "Darwin" ]]; then
  # SSH X forwarding
  export_alias ssh 'ssh -o "XAuthLocation=/opt/X11/bin/xauth"'

  #Open apps
  export_alias preview "open -a Preview"
  export_alias xcode "open -a Xcode"
  export_alias plistbuddy "/usr/libexec/PlistBuddy"
  export_alias safari "open -a safari"
  export_alias chrome "open -a Google\ Chrome"

  # Control volume
  export_alias mute 'osascript -e "set volume output muted true"'
  export_alias maxvol 'osascript -e "set volume output volume 100"'

  # Yabai
  export_alias restart_yabai 'launchctl kickstart -k "gui/${UID}/homebrew.mxcl.yabai"'
fi
#}}}

# For Linux {{{
if [[ "${UNAME:=$(uname -s)}" == "Linux" ]]; then
  # Setup alerts for long running commands
  export_alias alert 'notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history 1|sed '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
fi
#}}}

# vim:foldmethod=marker
