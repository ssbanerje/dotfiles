# .bashrc file for my mac
#####################################################################
# Author: Subho Sankar Banerjee
# EMail: subs.zero[at]gmail[dot]com
########################################################################

# Check if this is an interactive shell
if [ -z "$PS1" ]; then
   return
fi

#Do this only on MacOSX
if [ `uname` == 'Darwin' ]; then
  #Homebrew completion
  source $(brew --repo)/Library/Contributions/brew_bash_completion.sh
  #Get stuff from the profile file
  source $HOME/.profile.osx
fi

#Get stuff from the profile file
source $HOME/.profile

#Control history saves
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend

#Set reverse and forward search for arrow keys
bind '"\e[A"':history-search-backward
bind '"\e[B"':history-search-forward

# Make bash check its window size after a process completes
shopt -s checkwinsize

## Custom prompt
function _update_ps1()
{
   export PS1="$(~/.powerline-bash/powerline-bash.py $?)"
}
export PROMPT_COMMAND="_update_ps1"

