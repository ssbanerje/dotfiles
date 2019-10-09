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
init-prereqs-Linux:
	@sudo apt-get install -y global zsh ruby-dev libclang-dev exuberant-ctags\
		python3-pip vim-nox vim-gnome rake tmux cmake python3-dev xclip psutils\
		python3-pygments npm rsync neovim python3-neovim git curl
	@sudo snap install --classic clangd
	@sudo mkdir -p `npm config get prefix`/{lib/node_modules,bin,share}
	@sudo chown -R $(shell whoami) `npm config get prefix`/{lib/node_modules,bin,share}
init-prereqs-Darwin:
	@brew install ctags coreutils git ack python fasd tmux\
		reattach-to-user-namespace node neovim bash-completion global
	@brew tap homebrew/cask-fonts && brew cask install font-hack-nerd-font
init: init-prereqs-$(UNAME) init-submodules
	@python3 -m pip install --upgrade --user click jinja2 flake8 yapf autoflake\
		isort python-language-server powerline-status || 1
	@npm -g install remark remark-cli remark-stringify remark-frontmatter wcwidth prettier\
		bash-language-server javascript-typescript-langserver vscode-html-languageserver-bin



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
	@python3 generate_template.py --template-file git/gitconfig\
		--json-file config/git_config_db.json
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
	@cp -r editors/SpaceVim.d $(BUILD)/.SpaceVim.d



######## OS Specific ###########
build-common:
	@mkdir -p $(BUILD)/.bin
	@cp bin/gzball $(BUILD)/.bin/
	@cp bin/ports $(BUILD)/.bin/
	@cp bin/random $(BUILD)/.bin/
	@cp bin/diffconflicts $(BUILD)/.bin/
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
	@rsync -avz $(BUILD)/ ${HOME}
install-vim:
	@curl -sLf https://spacevim.org/install.sh | bash
install-fonts-Linux:
	@if command -v fc-cache; then \
		fc-cache -vf > /dev/null; \
	fi
	@if command -v mkfontdir; then \
		mkfontdir ${HOME}/.fonts > /dev/null; \
		mkfontscale ${HOME}/.fonts > /dev/null; \
	fi
	@if command -v gconftool-2; then \
	  gconftool-2 -t bool -s /apps/gnome-terminal/profiles/Default/use_system_font '0'; \
	  gconftool-2 -t bool -s /apps/gnome-terminal/profiles/Default/scrollback_unlimited '1'; \
	  gconftool-2 -t string -s /apps/gnome-terminal/profiles/Default/font 'Monaco For Powerline 10'; \
	  gconftool-2 -t bool -s /apps/meld/use_custom_font '1'; \
	  gconftool-2 -t string -s /apps/meld/custom_font 'Monospace 10'; \
	  gconftool-2 -t int -s /apps/meld/tab_size '2'; \
	fi
install-Darwin: install-common install-vim
install-Linux: install-common install-vim install-fonts-Linux



######## Clean ###########
clean:
	@rm -rf build/
