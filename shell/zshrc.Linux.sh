# Enable grc on all commands
[[ -s "/etc/grc.zsh" ]] && source /etc/grc.zsh
[ -z ls ] && unset -f ls # Do not want this from grc

# Enable fzf
[[ -s "/usr/share/doc/fzf/examples/completion.zsh" ]] && \
  source /usr/share/doc/fzf/examples/completion.zsh
