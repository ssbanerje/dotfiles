# Locale
export LANG="en_US.UTF-8"
export LANGUAGE="en_US:en"
export LC_CTYPE="UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_PAPER="en_US.UTF-8"
export LC_NAME="en_US.UTF-8"
export LC_ADDRESS="en_US.UTF-8"
export LC_TELEPHONE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_MEASUREMENT="en_US.UTF-8"
export LC_IDENTIFICATION="en_US.TF-8"

# Setup path helper
eval "$(/usr/libexec/path_helper -s)"

# Homebrew
if [[ ! "$PATH" == *"/usr/local/bin"* ]]; then
  export PATH="/usr/local/bin:$PATH"
fi
if [[ ! "$PATH" == *"/usr/local/sbin"* ]]; then
  export PATH="/usr/local/sbin:$PATH"
fi

# Use LLVM tools from homebrew vs Apple
if [[ ! "$PATH" == *"/usr/local/opt/llvm/bin"* ]]; then
  export PATH="/usr/local/opt/llvm/bin:$PATH"
fi

# TODO Remove when Python3 is default
export PATH="/usr/local/opt/python/libexec/bin:$PATH"
