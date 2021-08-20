# Set PATH to include non-standard locations
export PATH="$PATH:/usr/local/sbin:/usr/sbin:/sbin"

# Set for CUDA
CUDA=/usr/local/cuda
[ -d $CUDA ] && export PATH="$PATH:$CUDA/bin"

# Python Executables
export PATH="$PATH:$HOME/.local/bin"
