# Iterm2 Shell Intergration
if [[ -a $HOME/.config/iterm2_shell_integration.zsh ]]; then
  source $HOME/.config/iterm2_shell_integration.zsh
fi

# Setup fzf
function fzf_init() {
  [[ $- == *i* ]] && source "$(brew --prefix)/opt/fzf/shell/completion.zsh" 2> /dev/null
  source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
}
zvm_after_init_commands+=(fzf_init)

# Enable grc on all commands
[[ -s "$(brew --prefix)/etc/grc.zsh" ]] && source "$(brew --prefix)/etc/grc.zsh"
