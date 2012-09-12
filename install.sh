#!/bin/bash

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

cd "$(dirname "$0")"

#Initialize the repository
if [ "$1" == "--init" ]; then
  git submodule init
  git submodule update
fi

#Update the repository
if [ "$1" == "--update" ]; then
  git pull
  git submodule foreach git pull
fi

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
