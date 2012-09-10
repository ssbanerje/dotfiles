######################################################################
# .profile file for my mac
# Author: Subho Sankar Banerjee
# EMail: subs.zero[at]gmail[dot]com
########################################################################

#Aliases
alias ls='ls -G'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lq='ls -Q'
alias lr='ls -R'
alias lrs='ls -lrS'
alias lrt='ls -lrt'
alias lrta='ls -lrtA'
alias lrth='ls -lrth'
alias lrtha='ls -lrthA'
alias j='jobs -l'
alias tf='tail -f'
alias grep='grep --colour'
alias e='emacs -nw --quick'
alias v='vim -p'

# For convenience
alias mkdir='mkdir -p'
alias dus='du -ms * | sort -n'

# Typing errors...
alias 'cd..=cd ..'

# Play safe!
#alias rm='rmtrash'
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

#Aliases specifically for the Mac
alias grep='grep --color=auto --exclude="*.svn*"'
alias vncviewer='/System/Library/CoreServices/Screen\ Sharing.app/Contents/MacOS/Screen\ Sharing'
alias clc='/System/Library/Frameworks/OpenCL.framework/Libraries/openclc'
alias mplayerx='/Applications/MPlayerX.app/Contents/MacOS/MPlayerX'
alias gvim='mvim'
alias mou='/Applications/Mou.app/Contents/MacOS/Mou'
export EDITOR=mvim
export USE_EDITOR=mvim
export EDITOR=mvim
export SVN_EDITOR=mvim

#Set for ROOT
#export ROOTSYS=/opt/alice/root
#export ROOTBUILD=debug
#export PATH=$PATH:$ROOTSYS/bin

#Set for CUDA
CUDA=/usr/local/cuda
export PATH=$PATH:$CUDA/bin

#Set environment for MATLAB
export MATLAB=/Applications/MATLAB_R2010b.app
export PATH=$PATH:$MATLAB/bin

#Set for MacTex
export PATH=$PATH:/usr/texbin

#Set for nodejs
export PATH=$PATH:/usr/local/share/npm/bin

#For homebrew
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
alias pip="/usr/local/share/python/pip"
alias pipup="pip freeze --local | cut -d = -f 1  | xargs pip install -U"
alias ipython='/usr/local/share/python/ipython'
alias ipy='/usr/local/share/python/ipython qtconsole'
export PYTHONPATH="/usr/local/lib/python2.7/site-packages:$PYTHONPATH"

#Set Proxies
export http_proxy=http://proxy.iiit.ac.in:8080
export https_proxy=https://proxy.iiit.ac.in:8080
export proxy=$http_proxy
export ALL_PROXY=$http_proxy

#Locale
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
export LC_CTYPE=UTF-8
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_PAPER="en_US.UTF-8"
export LC_NAME="en_US.UTF-8"
export LC_ADDRESS="en_US.UTF-8"
export LC_TELEPHONE="en_US.UTF-8"
export LC_MEASUREMENT="en_US.UTF-8"
export LC_IDENTIFICATION="en_US.UTF-8"
export LC_ALL=

