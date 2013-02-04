UNAME := $(shell uname)
BUILD := build

build: init build-fonts-$(UNAME) build-git-$(UNAME) build-$(UNAME)
init: init-common init-vim

######## Init Everythning ###########
init-common:
        git submodule init
        git submodule update
init-vim:
        mkdir -p $(BUILD)/.vim/vim_backups
        mkdir -p $(BUILD)/.vim/vim_swp
        mkdir -p $(BUILD)/Documents

######## Fonts ###########
build-fonts-Darwin:
        mkdir -p $(BUILD)/Library/Fonts/
        rsync fonts/*.otf $(BUILD)/Library/Fonts/
build-fonts-Linux:
        mkdir -p $(BUILD)/.fonts
        rsync fonts/*.ttf $(BUILD)/.fonts

######## Git ###########
build-git-common:
        mkdir -p $(BUILD)/.global_gitinore
        rsync git/gitattributes $(BUILD)/.gitattributes
        cp -r git/gitignore/ $(BUILD)/.global_gitinore
build-git-Darwin: build-git-common
build-git-Linux: build-git-common

######## OS Specific ###########
build-Darwin:
        mkdir -p $(BUILD)/Library/Preferences/com.googlecode.iterm2.plist
        rsync com.googlecode.iterm2.plist $(BUILD)/Library/Preferences/com.googlecode.iterm2.plist

######## Install ###########
install-common:
        rsync $(BUILD)/ ${HOME}
install-Darwin: install-common
install-Linux: install-common
        fc-cache -vc

######## Clean ###########
clean:
        rm -rf build/
