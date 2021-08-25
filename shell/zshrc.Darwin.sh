# Iterm2 Shell Intergration
if [[ -a $HOME/.config/iterm2_shell_integration.zsh ]]; then
  source $HOME/.config/iterm2_shell_integration.zsh
fi

# Setup fzf
[[ $- == *i* ]] && source "$(brew --prefix)/opt/fzf/shell/completion.zsh" 2> /dev/null
source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"

# Enable grc on all commands
[[ -s "$(brew --prefix)/etc/grc.zsh" ]] && source "$(brew --prefix)/etc/grc.zsh"
type ls &> /dev/null && unset -f ls # Do not want this from grc
