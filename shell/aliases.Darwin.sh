#Aliases specifically for the Mac

# SSH X forwarding
alias ssh='ssh -o "XAuthLocation=/opt/X11/bin/xauth"'

#Apple apps
alias vncviewer='/System/Library/CoreServices/Screen\ Sharing.app/Contents/MacOS/Screen\ Sharing'
alias preview='open -a '$PREVIEW''
alias xcode='open -a '/Developer/Applications/Xcode.app''
alias safari='open -a safari'
alias mute='osascript -e "set volume output muted true"'
alias maxvol='osascript -e "set volume output volume 100"'
alias plistbuddy='/usr/libexec/PlistBuddy'

# Third party apps
alias chrome='open -a google\ chrome'
alias brewd='brew doctor'
alias brewi='brew install'
alias brewr='brew uninstall'
alias brews='brew search'
alias brewu='brew update && brew upgrade && brew cleanup'
