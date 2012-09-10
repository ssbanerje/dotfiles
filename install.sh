#!/bin/bash

# Get latest version of repository
cd "$(dirname "$0")"
git pull


function syncConfigs() {
	rsync --exclude "fonts" --exclude ".git/" --exclude ".gitignore" --exclude ".gitmodules" --exclude ".DS_Store" --exclude "install.sh" --exclude "README.md" -av . ~
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


# Compile anything if required
cd ~/.vim/bundle/Command-T/ruby/command-t/ && ruby extconf.rb && make

unset syncConfigs
