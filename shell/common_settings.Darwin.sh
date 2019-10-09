# Setup path for Homebrew
export PATH="/usr/local/sbin:$PATH"

# Set environment for MATLAB
export MATLAB=/Applications/MATLAB_R2015a.app
export PATH=$PATH:$MATLAB/bin

# Set for MacTex
export PATH=$PATH:/usr/texbin

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
export LC_IDENTIFICATION="en_US.UTF-8"

# Setup grc
if $(grc &>/dev/null)
then
    source `brew --prefix`/etc/grc.bashrc
fi

# Setup path helper
eval `/usr/libexec/path_helper -s`

# Setup fasd
eval "$(fasd --init auto)"

# Use LLVM tools from homebrew vs Apple
export PATH="/usr/local/opt/llvm/bin:$PATH"
