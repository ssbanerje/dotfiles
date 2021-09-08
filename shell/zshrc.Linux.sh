# Enable grc on all commands
if [[ -s "/etc/grc.zsh" ]]; then
  source /etc/grc.zsh
fi

# Enable fzf
if [[ -s "/usr/share/doc/fzf/examples/completion.zsh" ]]; then
  source /usr/share/doc/fzf/examples/completion.zsh
fi
if [[ -s "/usr/share/doc/fzf/examples/key-bindings.zsh" ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi
