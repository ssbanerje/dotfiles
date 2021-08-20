# Vim all the way
export VISUAL="nvim"
export EDITOR="nvim"
export USE_EDITOR="nvim"
export SVN_EDITOR="nvim"

# Export XDG_DATA_DIR
# TODO: Is this required on OSX?
export XDG_DATA_DIR=$HOME/.config

# My scripts
export PATH="$PATH:$HOME/.bin"

# Python startup settings
export PYTHONSTARTUP="$HOME/.pythonrc.py"

# Source Rustup
if [ -d "$HOME/.cargo/" ]
then
  source "$HOME/.cargo/env"
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# Setup aliases
source "$HOME/.config/aliases.sh"

# Platform specific
source "$HOME/.config/env.$(uname).sh"

# Setup NPM binaries
export PATH="$(yarn global bin):$PATH"
