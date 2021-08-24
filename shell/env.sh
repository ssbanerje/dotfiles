# Vim all the way
export VISUAL="nvim"
export EDITOR="nvim"
export USE_EDITOR="nvim"
export SVN_EDITOR="nvim"

# Setup GPG TTY
export GPG_TTY="$(tty)"

# Export XDG_DATA_DIR
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

# Platform specific
source "$HOME/.config/env.$(uname).sh"

# Setup NPM binaries (Needs to come after the homebrew is loaded)
export PATH="$(yarn global bin):$PATH"
