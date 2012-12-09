######################################################################
# .profile
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
alias e='emacs -nw --quick'
alias v='vim -p'
alias grep='grep --color=auto --exclude="*.svn*"'
alias mkdir='mkdir -p'
alias dus='du -ms * | sort -n'

# Play safe!
#alias rm='rmtrash'
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# Setup fasd
#eval "$(fasd --init auto)"

#Vim all the way
export EDITOR=vim
export USE_EDITOR=vim
export SVN_EDITOR=vim

#Set Proxies
#export http_proxy=http://proxy.iiit.ac.in:8080
#export https_proxy=https://proxy.iiit.ac.in:8080
#export proxy=$http_proxy
#export ALL_PROXY=$http_proxy

#Set for CUDA
CUDA=/usr/local/cuda
export PATH=$PATH:$CUDA/bin

#Set for Dia
export PATH=$PATH:/Applications/Dia.app/Contents/Resources/bin

#My scripts
export PATH=$PATH:$HOME/.bin

#Set for ROOT
#export ROOTSYS=/opt/alice/root
#export ROOTBUILD=debug
#export PATH=$PATH:$ROOTSYS/bin

#Start Python Shell with sensible settings
export PYTHONSTARTUP="$HOME/.pyrc"
export PYTHONPATH="/usr/local/lib/python2.7/site-packages:$PYTHONPATH"
alias pipup="pip freeze --local | cut -d = -f 1  | xargs pip install -U"
