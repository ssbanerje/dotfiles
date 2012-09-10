#!/bin/bash


cd "$(dirname "$0")"
git pull


function syncConfigs() {
	rsync --exclude ".git/" --exclude ".gitignore" --exclude ".DS_Store" --exclude "install.sh" --exclude "README.md" -av . ~
}


if [ "$1" == "--force" -o "$1" == "-f" ]; then
	syncConfigs
else
	read -p "Overwrite existing files? (y/n) " -n 1
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		syncConfigs
	fi
fi

cd ~/.vim/bundle/Command-T/ruby/command-t/ && ruby extconf.rb && make

unset syncConfigs
