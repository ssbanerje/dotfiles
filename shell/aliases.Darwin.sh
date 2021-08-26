#Aliases specifically for the Mac

# SSH X forwarding
alias ssh='ssh -o "XAuthLocation=/opt/X11/bin/xauth"'

#Apple apps
alias vncviewer='/System/Library/CoreServices/Screen\ Sharing.app/Contents/MacOS/Screen\ Sharing'
alias preview='open -a Preview'
alias xcode='open -a Xcode'
alias plistbuddy='/usr/libexec/PlistBuddy'

# Control volume
alias mute='osascript -e "set volume output muted true"'
alias maxvol='osascript -e "set volume output volume 100"'

# Browsers
alias safari='open -a safari'
alias chrome='open -a Google\ Chrome'

# Homebrew
alias brewd='brew doctor'
alias brewi='brew install'
alias brewr='brew uninstall'
alias brews='brew search'
alias brewu='brew update && brew upgrade && brew cleanup'

# Yabai
alias restart_yabai='launchctl kickstart -k "gui/${UID}/homebrew.mxcl.yabai"'
