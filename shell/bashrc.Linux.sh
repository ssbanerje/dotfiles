# Install bash completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Setup GRC for commands
[[ -s "/etc/grc.sh" ]] && source /etc/grc.sh
[ -z ls ] && unset -f ls # Do not want this from grc

# Setup fzf
[[ -s "/usr/share/doc/fzf/examples/completion.bash" ]] && \
  source /usr/share/doc/fzf/examples/completion.bash
