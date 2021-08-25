#Homebrew bash completion
[[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && source "$(brew --prefix)/etc/profile.d/bash_completion.sh"

# Iterm2 Bash Integration
[[ -r "$HOME/.config/iterm2_shell_integration.bash" ]] && source $HOME/.config/iterm2_shell_integration.bash

# Grc color on all commands
[[ -s "$(brew --prefix)/etc/grc.sh" ]] && source "$(brew --prefix)/etc/grc.sh"
type ls &> /dev/null && unset -f ls # Do not want this from grc
