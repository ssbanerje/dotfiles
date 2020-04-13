# Set PATH to include non-standard locations
export PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin:$HOME/.powerline/scripts

# Source color schemes
BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"
source ${HOME}/.config/base16-shell/scripts/base16-monokai.sh

# Set for CUDA
CUDA=/usr/local/cuda
export PATH=$PATH:$CUDA/bin

# Python Executables
export PATH=$PATH:$HOME/.local/bin
