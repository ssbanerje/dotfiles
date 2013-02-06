UNAME := $(shell uname)
BUILD := build
HOME := $(shell echo ${HOME} | sed 's/\//\\\//g')

build: clean init build-fonts-$(UNAME) build-git build-shell build-ssh build-interp build-editors build-$(UNAME)
init: init-vim

######## Init Everythning ###########
init-submodule:
	git submodule init
	git submodule update
init-vim:
	@echo '------------------------- Init ------------------------'
	mkdir -p $(BUILD)/.vim/vim_backups
	mkdir -p $(BUILD)/.vim/vim_swp
	mkdir -p $(BUILD)/Documents

######## Fonts ###########
build-fonts-Darwin:
	@echo '---------------------- Build fonts ---------------------'
	mkdir -p $(BUILD)/Library/Fonts/
	cp fonts/*.otf $(BUILD)/Library/Fonts/
build-fonts-Linux:
	@echo '---------------------- Build fonts ---------------------'
	mkdir -p $(BUILD)/.fonts
	cp fonts/*.ttf $(BUILD)/.fonts

######## Git ###########
build-git:
	@echo '---------------- Configurations for Git ----------------'
	mkdir -p $(BUILD)/.global_gitinore
	cp -r git/gitignore/ $(BUILD)/.global_gitinore
	cp git/gitconfig $(BUILD)/.gitconfig
	cp git/gitattributes $(BUILD)/.gitattributes
	sed -i .bak -e 's/<<GLOBALGITIGNORE>>/$(HOME)\/.global_gitinore/g' $(BUILD)/.gitconfig
	[ -e git/gitconfig.$(UNAME) ] && cat git/gitconfig.$(UNAME) >> $(BUILD)/.gitconfig

######## Shell stuff ###########
build-shell: build-bash build-zsh build-commands
	@echo '--------------- Configurations for Sh -------------------'
	cp shell/profile $(BUILD)/.profile
	[ -e shell/profile.$(UNAME).sh ] && cat shell/profile.$(UNAME).sh >> $(BUILD)/.profile
build-commands:
	@echo '---------- Configurations for Shell Commands ------------'
	cp shell/ackrc $(BUILD)/.ackrc
	cp shell/hushlogin $(BUILD)/.hushlogin
	cp shell/screenrc $(BUILD)/.screenrc
	cp shell/toprc $(BUILD)/.toprc
	cp shell/npmrc $(BUILD)/.npmrc
build-bash:
	@echo '-------------- Configurations for Bash -----------------'
	cp shell/bash_profile $(BUILD)/.bash_profile
	cp shell/bashrc $(BUILD)/.bashrc
	cat shell/bash.prompt.sh >> $(BUILD)/.bashrc
	[ -e shell/bashrc.$(UNAME).sh ] && cat shell/bashrc.$(UNAME).sh >> $(BUILD)/.bashrc
build-zsh:
	@echo '---------------- Configurations for ZSH ----------------'
	cp shell/zshrc $(BUILD)/.zshrc
	cp -r shell/oh-my-zsh/ $(BUILD)/.oh-my-zsh
	mkdir -p $(BUILD)/.oh-my-zsh/custom/plugins/
	cp -r shell/zsh-syntax-highlighting/ $(BUILD)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
	cat shell/zshrc.prompt.sh >> $(BUILD)/.zshrc
	[ -e shell/zshrc.$(UNAME).sh ] && cat shell/zshrc.$(UNAME).sh >> $(BUILD)/.zshrc

########## For SSH #############
build-ssh:
	@echo '---------------- Configurations for SSH ----------------'
	mkdir -p $(BUILD)/.ssh/
	cp ssh/config $(BUILD)/.ssh/

######## For Interps ###########
build-interp:
	@echo '-------------- Configurations for Interps --------------'
	cp interp/pyrc $(BUILD)/.pyrc
	cp interp/irbrc $(BUILD)/.irbrc

######## For Editors ###########
build-editors: build-vim
	@echo '-------------- Configurations for Editors --------------'
	cp editors/editorconfig $(BUILD)/.editorconfig
build-vim:
	@echo '---------------- Configurations for VIM ----------------'
	cp editors/vimrc $(BUILD)/.vimrc
	cp -r editors/vim $(BUILD)/.vim

######## OS Specific ###########
build-common:
	@echo '-------------- Configurations for Scripts --------------'
	mkdir -p $(BUILD)/.bin
	cp bin/gzball $(BUILD)/.bin/
	cp bin/ports $(BUILD)/.bin/
	cp bin/talkto $(BUILD)/.bin/
	cp bin/wikisearch $(BUILD)/.bin/
build-Darwin: build-common
	@echo '---------------- Configurations for OSX ----------------'
	mkdir -p $(BUILD)/Library/Preferences/com.googlecode.iterm2.plist
	cp osx/com.googlecode.iterm2.plist $(BUILD)/Library/Preferences/com.googlecode.iterm2.plist
	cp osx/lock-screen $(BUILD)/.bin/
	cp osx/lyrics $(BUILD)/.bin/
build-Linux: build-common

######## Install ###########
install-common:
	rsync $(BUILD)/ ${HOME}
install-Darwin: install-common
install-Linux: install-common
	fc-cache -vc

######## Clean ###########
clean:
	@echo '--------------------- Clean Up -----------------------'
	rm -rf build/
