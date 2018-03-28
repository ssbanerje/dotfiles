UNAME := $(shell uname)
BUILD := build
HOME_ESCAPED := $(shell echo ${HOME} | sed 's/\//\\\//g')

.PHONY: build install
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
init-submodules:
	@git submodule update --init --recursive
init: init-submodules
	@python3 -m pip install --upgrade --user click jinja2 || 1



######## Fonts ###########
build-fonts-Darwin:
	@mkdir -p $(BUILD)/Library/Fonts/
	@cp fonts/* $(BUILD)/Library/Fonts/
build-fonts-Linux:
	@mkdir -p $(BUILD)/.fonts
	@cp fonts/* $(BUILD)/.fonts



######## Git ###########
build-git:
	@cat git/gitignore/Global/*.gitignore > $(BUILD)/.global_gitignore
	@python3 generate_template.py --template-file git/gitconfig --json-file config/git_config_db.json
	@mv $(BUILD)/gitconfig $(BUILD)/.gitconfig
	@cp git/gitattributes $(BUILD)/.gitattributes



######## Shell stuff ###########
build-shell: build-sh build-bash build-zsh build-commands build-tmux
build-sh:
	@mkdir -p $(BUILD)/.config
	@cp shell/common_settings $(BUILD)/.config/common_settings
	@[ -e shell/common_settings.$(UNAME).sh ] && cat shell/common_settings.$(UNAME).sh >> $(BUILD)/.config/common_settings
	@cp shell/aliases $(BUILD)/.config/aliases
	@[ -e shell/aliases.$(UNAME).sh ] && cat shell/aliases.$(UNAME).sh >> $(BUILD)/.config/aliases
build-bash:
	@cp shell/bash_profile $(BUILD)/.bash_profile
	@cp shell/bashrc $(BUILD)/.bashrc
	@cat shell/bash.prompt.sh >> $(BUILD)/.bashrc
	@[ -e shell/bashrc.$(UNAME).sh  ] && cat shell/bashrc.$(UNAME).sh >> $(BUILD)/.bashrc
build-zsh:
	@mkdir -p $(BUILD)/.config
	@cp -r shell/oh-my-zsh/ $(BUILD)/.config/oh-my-zsh
	@mkdir -p $(BUILD)/.config/oh-my-zsh/custom/plugins/
	@cp -r shell/zsh-syntax-highlighting/ $(BUILD)/.config/oh-my-zsh/custom/plugins/zsh-syntax-highlighting
	@python3 generate_template.py --template-file shell/zshrc --json-file config/zsh_config_db.json
	@mv build/zshrc build/.zshrc
build-commands:
	@cp shell/ackrc $(BUILD)/.ackrc
	@cp shell/hushlogin $(BUILD)/.hushlogin
	@cp shell/screenrc $(BUILD)/.screenrc
	@cp shell/toprc $(BUILD)/.toprc
	@cp shell/npmrc $(BUILD)/.npmrc
build-tmux:
	@mkdir -p $(BUILD)/.tmux/plugins
	@rsync -r shell/tpm $(BUILD)/.tmux/plugins/tpm
	@python3 generate_template.py --template-file shell/tmux.conf --json-file config/tmux_conf_db.json
	@mv build/tmux.conf build/.tmux.conf



########## For SSH #############
build-ssh:
	@mkdir -p $(BUILD)/.ssh/
	@cp ssh/config $(BUILD)/.ssh/



######## For Interps ###########
build-interp:
	@cp interp/pyrc $(BUILD)/.pyrc
	@cp interp/irbrc $(BUILD)/.irbrc



######## For Editors ###########
build-editors: build-vim
	@cp editors/editorconfig $(BUILD)/.editorconfig
build-vim:
	@cp -r editors/spacevim $(BUILD)/.SpaceVim



######## OS Specific ###########
build-common:
	@mkdir -p $(BUILD)/.bin
	@cp bin/gzball $(BUILD)/.bin/
	@cp bin/ports $(BUILD)/.bin/
	@cp bin/wikisearch $(BUILD)/.bin/
	@cp bin/random $(BUILD)/.bin/
build-Darwin: build-common
	@mkdir -p $(BUILD)/Library/Preferences/
	@cp osx/com.googlecode.iterm2.plist $(BUILD)/Library/Preferences/com.googlecode.iterm2.plist
	@cp osx/lock-screen $(BUILD)/.bin/
	@cp osx/lyrics $(BUILD)/.bin/
	@cp -r osx/hammerspoon $(BUILD)/.hammerspoon
build-Linux: build-common
	@cp -r shell/base16-shell $(BUILD)/.config/base16-shell



######## Install ###########
install-common:
	@rsync -av $(BUILD)/ ${HOME}
	@cd ${HOME}/.powerline && python3 setup.py build && python3 setup.py install --user
install-vim:
	@if [ ! -d ${HOME}/.vim ]; then \
    echo "Hello";\
    ln -s ${HOME}/.SpaceVim ${HOME}/.vim; \
  fi
	@if [ ! -d ${HOME}/.config/nvim ]; then \
    echo "World";\
    mkdir -p ${HOME}/.config; \
    ln -s ${HOME}/.SpaceVim ${HOME}/.config/nvim; \
  fi
	@if [ ! -d ${HOME}/.cache/vimfiles/repos/github.com/Shougo/dein.vim ]; then \
    git clone https://github.com/Shougo/dein.vim.git ${HOME}/.cache/vimfiles/repos/github.com/Shougo/dein.vim; \
  else \
    git -C ${HOME}/.cache/vimfiles/repos/github.com/Shougo/dein.vim pull origin master; \
  fi
install-fonts-Linux:
	@fc-cache -vf > /dev/null
	@mkfontdir ${HOME}/.fonts > /dev/null
	@mkfontscale ${HOME}/.fonts > /dev/null
	@gconftool-2 -t bool -s /apps/gnome-terminal/profiles/Default/use_system_font '0'
	@gconftool-2 -t bool -s /apps/gnome-terminal/profiles/Default/scrollback_unlimited '1'
	@gconftool-2 -t string -s /apps/gnome-terminal/profiles/Default/font 'Monaco For Powerline 10'
	@gconftool-2 -t bool -s /apps/meld/use_custom_font '1'
	@gconftool-2 -t string -s /apps/meld/custom_font 'Monospace 10'
	@gconftool-2 -t int -s /apps/meld/tab_size '2'
install-Darwin: install-common install-vim
install-Linux: install-common install-vim install-fonts-Linux



######## Clean ###########
clean:
	@rm -rf build/
