# Set PATH to include non-standard locations
if [[ ! "$PATH" == *"/usr/local/sbin"* ]]; then
  export PATH="$PATH:/usr/local/sbin"
fi
if [[ ! "$PATH" == *"/usr/sbin"* ]]; then
  export PATH="$PATH:/usr/sbin"
fi
if [[ ! "$PATH" == *"/sbin"* ]]; then
  export PATH="$PATH:/sbin"
fi

# Set for CUDA
CUDA=/usr/local/cuda
[ -d $CUDA ] && if [[ ! "$PATH" == *"$CUDA/bin"* ]]; then
  export PATH="$PATH:$CUDA/bin"
fi
unset CUDA

# Python Executables
if [[ ! "$PATH" == *"$HOME/.local/bin"* ]]; then
  export PATH="$PATH:$HOME/.local/bin"
fi
