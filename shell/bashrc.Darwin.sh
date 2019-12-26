#Homebrew bash completion
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

# Iterm2 Bash Integration
[[ -r "$HOME/.config/iterm2_shell_integration.bash" ]] && source $HOME/.config/iterm2_shell_integration.bash
