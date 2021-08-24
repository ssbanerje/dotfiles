alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

if [[ $(uname -s) == 'Darwin' ]]; then
  alias ls='ls -G'
else
  alias ls='ls --color=auto'
fi
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

alias mkdir='mkdir -p'

alias grep='grep --color=auto --exclude="*.svn*"'
alias tf='tail -f'
alias dus='du -hs * | sort -n'

alias j='jobs -l'

alias r='ranger'

alias pipup='pip freeze --local | cut -d = -f 1  | xargs pip install -U'
alias pip3up='pip3 freeze --local | cut -d = -f 1  | xargs pip3 install -U'

alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"

# Normalize `open` across Linux, macOS, and Windows.
if [ ! $(uname -s) = 'Darwin' ]; then
	if grep -q Microsoft /proc/version; then
		# Ubuntu on Windows using the Linux subsystem
		alias open='explorer.exe';
	else
		alias open='xdg-open';
	fi
fi

# Load platform specific
source "$HOME/.config/aliases.$(uname -s).sh"
