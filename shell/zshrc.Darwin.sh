# Homebrew
if (( ! ${fpath[(I)/usr/local/share/zsh/site-functions]} )); then
  FPATH="/usr/local/share/zsh/site-functions:$FPATH"
fi

# Iterm2 Shell Intergration
if [[ "$TERM_PROGRAM" == "iTerm.app" && -f "$HOME/.config/iterm2_shell_integration.zsh" ]]; then
  source "$HOME/.config/iterm2_shell_integration.zsh"
fi

# Setup fzf
[[ $- == *i* ]] && source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"

# Enable grc on all commands
[[ -f "$(brew --prefix)/etc/grc.zsh" ]] && source "$(brew --prefix)/etc/grc.zsh"
