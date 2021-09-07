# Enable grc on all commands
[[ -s "/etc/grc.zsh" ]] && source /etc/grc.zsh

# Enable fzf
if [[ -s "/usr/share/doc/fzf/examples/completion.zsh" ]]; then
  source /usr/share/doc/fzf/examples/completion.zsh
fi
if [[ -s "/usr/share/doc/fzf/examples/key-bindings.zsh" ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi
