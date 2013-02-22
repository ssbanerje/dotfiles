#Homebrew bash completion
source $(brew --repo)/Library/Contributions/brew_bash_completion.sh

#Get stuff from the profile file
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi
