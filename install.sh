#!/bin/bash

function syncConfigs() {
	rsync --exclude "fonts"\
    --exclude ".git/"\
    --exclude ".gitignore"\
    --exclude ".gitmodules"\
    --exclude ".DS_Store"\
    --exclude "com.googlecode.iterm2.plist"\
    --exclude "install.sh"\
    --exclude "*.png"\
    --exclude "README.md" -av . ~
}

cd "$(dirname "$0")"

#Initialize the repository
if [ "$1" == "--init" ]; then
  git submodule init
  git submodule update
  mkdir -p ~/.vim/vim_backups
  mkdir -p ~/.vim/vim_swp
  mkdir -p ~/Documents/Notes
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
		#Copy dotfiles
    syncConfigs
    #Copy everything else
    if [ `uname` == "Darwin" ]; then
      cp com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist
      cp fonts/*.otf ~/Library/Fonts 
    else
      cp fonts/*.ttf ~/.fonts.dir
      fc-cache -vf
    fi
	fi
fi

unset syncConfigs

