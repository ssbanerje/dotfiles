UNAME := $(shell uname)
BUILD := build
HOME := $(shell echo ${HOME} | sed 's/\//\\\//g')

build: init build-fonts-$(UNAME) build-git build-$(UNAME)
init: init-vim

######## Init Everythning ###########
init-submodule:
	git submodule init
	git submodule update
init-vim:
	mkdir -p $(BUILD)/.vim/vim_backups
	mkdir -p $(BUILD)/.vim/vim_swp
	mkdir -p $(BUILD)/Documents

######## Fonts ###########
build-fonts-Darwin:
	@echo '---------------------- Build fonts ---------------------'
	mkdir -p $(BUILD)/Library/Fonts/
	rsync fonts/*.otf $(BUILD)/Library/Fonts/
build-fonts-Linux:
	@echo '---------------------- Build fonts ---------------------'
	mkdir -p $(BUILD)/.fonts
	rsync fonts/*.ttf $(BUILD)/.fonts

######## Git ###########
build-git:
	@echo '---------------- Configurations for Git ----------------'
	mkdir -p $(BUILD)/.global_gitinore
	cp -r git/gitignore/ $(BUILD)/.global_gitinore
	rsync git/gitconfig $(BUILD)/.gitconfig
	rsync git/gitattributes $(BUILD)/.gitattributes
	sed -i .bak -e 's/<<GLOBALGITIGNORE>>/$(HOME)\/.global_gitinore/g' $(BUILD)/.gitconfig
	cat git/gitconfig.$(UNAME) >> $(BUILD)/.gitconfig

######## OS Specific ###########
build-Darwin:
	@echo '---------------- Configurations for OSX ----------------'
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
