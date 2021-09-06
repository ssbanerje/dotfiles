#Aliases specifically for the Mac

# SSH X forwarding
alias ssh='ssh -o "XAuthLocation=/opt/X11/bin/xauth"'

#Open apps
alias preview='open -a Preview'
alias xcode='open -a Xcode'
alias plistbuddy='/usr/libexec/PlistBuddy'
alias safari='open -a safari'
alias chrome='open -a Google\ Chrome'

# Control volume
alias mute='osascript -e "set volume output muted true"'
alias maxvol='osascript -e "set volume output volume 100"'

# Yabai
alias restart_yabai='launchctl kickstart -k "gui/${UID}/homebrew.mxcl.yabai"'
