# Source color schemes
BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"
source ${HOME}/.config/base16-shell/scripts/base16-monokai.sh

# Set rate for repeated characters
xset r rate 300 50
