# Install bash completion
if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    source /etc/bash_completion
  fi
fi

# Setup GRC for commands
if [[ -s "/etc/grc.sh" ]]; then
  source /etc/grc.sh
fi

# Setup fzf
if [[ -s "/usr/share/doc/fzf/examples/completion.bash" ]]; then
  source /usr/share/doc/fzf/examples/completion.bash
fi
if [[ -s "/usr/share/doc/fzf/examples/key-bindings.bash" ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.bash
fi
