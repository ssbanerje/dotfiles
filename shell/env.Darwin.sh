# Setup path helper
eval "$(/usr/libexec/path_helper -s)"

# Homebrew
if [[ ! "$PATH" == *"/usr/local/bin"* ]]; then
  export PATH="/usr/local/bin:$PATH"
fi
if [[ ! "$PATH" == *"/usr/local/sbin"* ]]; then
  export PATH="/usr/local/sbin:$PATH"
fi
export PATH="/usr/local/opt/python/libexec/bin:$PATH" #< TODO Remove when Python3 is default

# Use LLVM tools from homebrew vs Apple
if [[ ! "$PATH" == *"/usr/local/opt/llvm/bin"* ]]; then
  export PATH="/usr/local/opt/llvm/bin:$PATH"
fi
