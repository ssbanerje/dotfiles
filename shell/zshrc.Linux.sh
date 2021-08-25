# Enable grc on all commands
[[ -s "/etc/grc.zsh" ]] && source /etc/grc.zsh
#type ls &> /dev/null && unset -f ls # Do not want this from grc

# Enable fzf
[[ -s "/usr/share/doc/fzf/examples/completion.zsh" ]] && \
  source /usr/share/doc/fzf/examples/completion.zsh
[[ -s "/usr/share/doc/fzf/examples/key-bindings.zsh" ]] && \
  source /usr/share/doc/fzf/examples/key-bindings.zsh
