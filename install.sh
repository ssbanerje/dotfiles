#!/bin/bash

# Get latest version of repository
cd "$(dirname "$0")"
git pull


function syncConfigs() {
	rsync --exclude "fonts"\
    --exclude ".git/"\
    --exclude ".gitignore"\
    --exclude ".gitmodules"\
    --exclude ".DS_Store"\
    --exclude "com.googlecode.iterm2.plist"\
    --exclude "install.sh"\
    --exclude "README.md" -av . ~
}

# Copy things into their right place
if [ "$1" == "--force" -o "$1" == "-f" ]; then
	syncConfigs
else
	read -p "Overwrite existing files? (y/n) " -n 1
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		syncConfigs
	fi
fi
cp com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist

unset syncConfigs
