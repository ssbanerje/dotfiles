UNAME := $(shell uname)
BUILD := build
HOME_ESCAPED := $(shell echo ${HOME} | sed 's/\//\\\//g')

build: clean\
  init\
  build-fonts-$(UNAME)\
  build-git\
  build-shell\
  build-ssh\
  build-interp\
  build-editors\
  build-$(UNAME)

install: install-common\
  install-$(UNAME)

######## Init ###########
init:
	@echo '---------------- Init ----------------'
	git submodule update --init --recursive
	pip install --upgrade --user click jinja2 || 1



######## Fonts ###########
build-fonts-Darwin:
	@echo '---------------- Copying Fonts ----------------'
	mkdir -p $(BUILD)/Library/Fonts/
	cp fonts/* $(BUILD)/Library/Fonts/
build-fonts-Linux:
	@echo '---------------- Copying Fonts ----------------'
	mkdir -p $(BUILD)/.fonts
	cp fonts/* $(BUILD)/.fonts



######## Git ###########
build-git:
	@echo '---------------- Configurations for Git ----------------'
	cat git/gitignore/Global/*.gitignore > $(BUILD)/.global_gitignore
	python generate_template.py --template-file git/gitconfig --json-file config/git_config_db.json
	mv $(BUILD)/gitconfig $(BUILD)/.gitconfig
	cp git/gitattributes $(BUILD)/.gitattributes



######## Shell stuff ###########
build-shell: build-sh build-bash build-zsh build-commands build-tmux
build-sh:
	@echo '--------------- Configurations for Sh -------------------'
	cp shell/common_settings $(BUILD)/.common_settings
	[ -e shell/common_settings.$(UNAME).sh ] && cat shell/common_settings.$(UNAME).sh >> $(BUILD)/.common_settings
	cp shell/aliases $(BUILD)/.aliases
	[ -e shell/aliases.$(UNAME).sh ] && cat shell/aliases.$(UNAME).sh >> $(BUILD)/.aliases
build-bash:
	@echo '-------------- Configurations for Bash -----------------'
	cp shell/bash_profile $(BUILD)/.bash_profile
	cp shell/bashrc $(BUILD)/.bashrc
	cat shell/bash.prompt.sh >> $(BUILD)/.bashrc
	[ -e shell/bashrc.$(UNAME).sh  ] && cat shell/bashrc.$(UNAME).sh >> $(BUILD)/.bashrc
build-zsh:
	@echo '---------------- Configurations for ZSH ----------------'
	cp -r shell/oh-my-zsh/ $(BUILD)/.oh-my-zsh
	mkdir -p $(BUILD)/.oh-my-zsh/custom/plugins/
	cp -r shell/zsh-syntax-highlighting/ $(BUILD)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
	python generate_template.py --template-file shell/zshrc --json-file config/zsh_config_db.json
	mv build/zshrc build/.zshrc
build-commands:
	@echo '---------- Configurations for Shell Commands ------------'
	cp shell/ackrc $(BUILD)/.ackrc
	cp shell/hushlogin $(BUILD)/.hushlogin
	cp shell/screenrc $(BUILD)/.screenrc
	cp shell/toprc $(BUILD)/.toprc
	cp shell/npmrc $(BUILD)/.npmrc
build-tmux:
	@echo '------------------ Configurations TMUX ------------------'
	mkdir -p $(BUILD)/.tmux/plugins
	rsync -r shell/tpm $(BUILD)/.tmux/plugins/tpm
	python generate_template.py --template-file shell/tmux.conf --json-file config/tmux_conf_db.json
	mv build/tmux.conf build/.tmux.conf



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
	mkdir -p $(BUILD)/.vim/vim_backups
	mkdir -p $(BUILD)/.vim/vim_swp
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
	cp -r osx/hammerspoon $(BUILD)/.hammerspoon
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
