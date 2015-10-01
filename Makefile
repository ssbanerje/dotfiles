UNAME := $(shell uname)
BUILD := build
HOME_ESCAPED := $(shell echo ${HOME} | sed 's/\//\\\//g')

build: clean init-vim build-fonts-$(UNAME) build-git build-shell build-ssh build-interp build-editors build-$(UNAME)
install: install-common install-$(UNAME)
init: init-vim init-submodule

######## Init Everythning ###########
init-submodule:
	git submodule update --init --recursive
init-vim:
	@echo '------------------------- Init ------------------------'
	mkdir -p $(BUILD)/.vim/vim_backups
	mkdir -p $(BUILD)/.vim/vim_swp

######## Fonts ###########
build-fonts-Darwin:
	@echo '---------------------- Build fonts ---------------------'
	mkdir -p $(BUILD)/Library/Fonts/
	cp fonts/* $(BUILD)/Library/Fonts/
build-fonts-Linux:
	@echo '---------------------- Build fonts ---------------------'
	mkdir -p $(BUILD)/.fonts
	cp fonts/* $(BUILD)/.fonts

######## Git ###########
build-git:
	@echo '---------------- Configurations for Git ----------------'
	cat git/gitignore/Global/*.gitignore > $(BUILD)/.global_gitignore
	cp git/gitconfig $(BUILD)/.gitconfig
	cp git/gitattributes $(BUILD)/.gitattributes
	sed -i.bak -e 's/<<GLOBALGITIGNORE>>/$(HOME_ESCAPED)\/.global_gitignore/g' $(BUILD)/.gitconfig
	[ -e git/gitconfig.$(UNAME) ] && cat git/gitconfig.$(UNAME) >> $(BUILD)/.gitconfig

######## Shell stuff ###########
build-shell: build-bash build-zsh build-commands build-tmux
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
build-tmux:
	cp shell/tmux.conf $(BUILD)/.tmux.conf
	echo "set -g status-right '#($(HOME)/.powerline/scripts/powerline tmux right)'" >> $(BUILD)/.tmux.conf
	echo "source '$(HOME)/.powerline/powerline/bindings/tmux/powerline.conf'" >> $(BUILD)/.tmux.conf
build-bash:
	@echo '-------------- Configurations for Bash -----------------'
	cp shell/bash_profile $(BUILD)/.bash_profile
	cp shell/bashrc $(BUILD)/.bashrc
	cat shell/bash.prompt.sh >> $(BUILD)/.bashrc
	[ -e shell/bashrc.$(UNAME).sh ] && cat shell/bashrc.$(UNAME).sh >> $(BUILD)/.bashrc
build-zsh:
	@echo '---------------- Configurations for ZSH ----------------'
	cp shell/zshrc.prompt.$(UNAME).sh $(BUILD)/.zshrc
	cat shell/zshrc >> $(BUILD)/.zshrc
	[ -e shell/zshrc.$(UNAME).sh ] && cat shell/zshrc.$(UNAME).sh >> $(BUILD)/.zshrc
	cp -r shell/oh-my-zsh/ $(BUILD)/.oh-my-zsh
	mkdir -p $(BUILD)/.oh-my-zsh/custom/plugins/
	cp -r shell/zsh-syntax-highlighting/ $(BUILD)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting


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
build-editors: build-vim build-emacs
	@echo '-------------- Configurations for Editors --------------'
	cp editors/editorconfig $(BUILD)/.editorconfig
build-vim:
	@echo '---------------- Configurations for VIM ----------------'
	cp editors/vimrc $(BUILD)/.vimrc
	cp -r editors/vim/* $(BUILD)/.vim/
	cp -r editors/powerline/ $(BUILD)/.powerline
build-emacs:
	@echo '---------------- Configurations for EMACS ----------------'
	cp editors/spacemacs $(BUILD)/.spacemacs
	cp -r editors/emacs/spacemacs $(BUILD)/.emacs.d/

######## OS Specific ###########
build-common:
	@echo '-------------- Configurations for Scripts --------------'
	mkdir -p $(BUILD)/.bin
	cp bin/gzball $(BUILD)/.bin/
	cp bin/ports $(BUILD)/.bin/
	cp bin/wikisearch $(BUILD)/.bin/
	cp bin/random $(BUILD)/.bin/
build-Darwin: build-common
	@echo '---------------- Configurations for OSX ----------------'
	mkdir -p $(BUILD)/Library/Preferences/
	cp osx/com.googlecode.iterm2.plist $(BUILD)/Library/Preferences/com.googlecode.iterm2.plist
	cp osx/lock-screen $(BUILD)/.bin/
	cp osx/lyrics $(BUILD)/.bin/
build-Linux: build-common
	@echo '-------------- Configurations for Linux---------------'
	if [ -e /usr/bin/conky ] ;\
  then\
    cp shell/conkyrc $(BUILD)/.conkyrc;\
  fi;
	cp -r shell/base16-shell $(BUILD)/.shellcolors

######## Install ###########
install-common:
	rsync -av $(BUILD)/ ${HOME}
	vim -c PlugInstall -c qa!
install-Darwin: install-common
	cd ${HOME}/.powerline && python setup.py build && python setup.py install
install-Linux: install-common
	fc-cache -vf
	gconftool-2 -t bool -s /apps/gnome-terminal/profiles/Default/use_system_font '0'
	gconftool-2 -t bool -s /apps/gnome-terminal/profiles/Default/scrollback_unlimited '1'
	gconftool-2 -t string -s /apps/gnome-terminal/profiles/Default/font 'Monaco For Powerline 10'
	gconftool-2 -t bool -s /apps/meld/use_custom_font '1'
	gconftool-2 -t string -s /apps/meld/custom_font 'Monospace 10'
	gconftool-2 -t int -s /apps/meld/tab_size '2'
	cd ${HOME}/.powerline && python setup.py build && python setup.py install --user

######## Clean ###########
clean:
	@echo '--------------------- Clean Up -----------------------'
	rm -rf build/
