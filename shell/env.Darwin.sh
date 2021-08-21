# Setup path helper
eval `/usr/libexec/path_helper -s`

# Homebrew
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/python/libexec/bin:$PATH" #< TODO Remove when Python3 is default

# Set for MacTex
export PATH="$PATH:/usr/texbin"

# Use LLVM tools from homebrew vs Apple
export PATH="/usr/local/opt/llvm/bin:$PATH"
