# Iterm2 Shell Intergration
if [[ -a $HOME/.config/iterm2_shell_integration.zsh ]]; then
  source $HOME/.config/iterm2_shell_integration.zsh
fi

# Enable grc on all commands
[[ -s "$(brew --prefix)/etc/grc.zsh" ]] && source "$(brew --prefix)/etc/grc.zsh"
[ -z ls ] && unset -f ls # Do not want this from grc
