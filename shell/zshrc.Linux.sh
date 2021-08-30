# Enable grc on all commands
[[ -s "/etc/grc.zsh" ]] && source /etc/grc.zsh

# Enable fzf
function fzf_init() {
  [[ -s "/usr/share/doc/fzf/examples/completion.zsh" ]] && \
    source /usr/share/doc/fzf/examples/completion.zsh
  [[ -s "/usr/share/doc/fzf/examples/key-bindings.zsh" ]] && \
    source /usr/share/doc/fzf/examples/key-bindings.zsh
}
zvm_after_init_commands+=(fzf_init)
