# Aliases specifically for the Mac
alias vncviewer='/System/Library/CoreServices/Screen\ Sharing.app/Contents/MacOS/Screen\ Sharing'
alias clc='/System/Library/Frameworks/OpenCL.framework/Libraries/openclc'
alias preview="open -a '$PREVIEW'"
alias xcode="open -a '/Developer/Applications/Xcode.app'"
alias safari="open -a safari"
alias chrome="open -a google\ chrome"
alias f='open -a Finder'
alias vim='mvim -v'
alias gvim='mvim'

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
