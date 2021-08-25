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
if [[ ! "$PATH" == *"$HOME/.bin"* ]]; then
  export PATH="${PATH:+${PATH}:}$HOME/.bin"
fi

# Python startup settings
export PYTHONSTARTUP="$HOME/.pythonrc.py"

# Source Rustup
if [ -d "$HOME/.cargo/" ]
then
  source "$HOME/.cargo/env"
  if [[ ! "$PATH" == *"$HOME/.cargo.bin"* ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
  fi
fi

# Platform specific
source "$HOME/.config/env.$(uname -s).sh"

# Setup NPM binaries (Needs to come after the homebrew is loaded)
YARN_PATH="$(yarn global bin)"
if [[ ! "$PATH" == *"$YARN_PATH"* ]]; then
  export PATH="YARN_PATH:${PATH}"
fi
unset YARN_PATH
