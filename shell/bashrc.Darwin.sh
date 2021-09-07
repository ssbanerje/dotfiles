#Homebrew bash completion
if [[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]]; then
  source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
fi

# Iterm2 Bash Integration
if [[ -r "$HOME/.config/iterm2_shell_integration.bash" ]]; then
  source $HOME/.config/iterm2_shell_integration.bash
fi

# Setup fzf
if [[ $- == *i* ]]; then
  source "$(brew --prefix)/opt/fzf/shell/completion.bash" 2> /dev/null
fi
source "$(brew --prefix)/opt/fzf/shell/key-bindings.bash"

# Grc color on all commands
if [[ -s "$(brew --prefix)/etc/grc.sh" ]]; then
  source "$(brew --prefix)/etc/grc.sh"
fi
