######## Variables ###########
UNAME := $(shell uname)
BUILD := $(shell pwd)/build
SUBDIRS := bin editors fonts git interp osx shell ssh
TARGETS := # This defines the targets built by "all"
BACKUPFOLDER := $(HOME)/old_dotfiles


######## Build ###########
.PHONY: all
all: # Dependencies are set later

include $(addsuffix /module.mak, $(SUBDIRS))

all: $(TARGETS)

$(BUILD):
	@echo "- Creating $@"
	@mkdir -p $(BUILD)

$(BUILD)/.config:
	@echo "- Creating $@"
	@mkdir -p $(BUILD)/.config


######## Init ###########
.PHONY: init-prereqs-Linux
init-prereqs-Linux:
	@curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
	@echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
	@sudo apt-get update && \
		sudo apt-get install -y global zsh ruby-dev libclang-dev exuberant-ctags\
		python3-pip vim-nox vim-gnome rake tmux cmake python3-dev xclip psutils\
		python3-pygments rsync neovim python3-neovim git curl yarn global
	@sudo snap install --classic clangd
	@npm config set prefix ~/.npm
	@sudo mkdir -p `npm config get prefix`/{lib/node_modules,bin,share}
	@sudo chown -R $(shell whoami) `npm config get prefix`/{lib/node_modules,bin,share}

.PHONY: init-prereqs-Darwin
init-prereqs-Darwin:
	@brew upgrade
	@brew install ctags coreutils git ack python fasd tmux\
		reattach-to-user-namespace node neovim bash-completion global blueutil
	@brew tap homebrew/cask-fonts && brew cask install font-hack-nerd-font

.PHONY: init
init: init-prereqs-$(UNAME)
	@git submodule update --init --recursive
	@python3 -m pip install --upgrade --user click jinja2 flake8 yapf autoflake\
		isort neovim 'python-language-server[all]'
	@npm -g --production install remark remark-cli remark-stringify remark-frontmatter wcwidth prettier\
		javascript-typescript-langserver vscode-html-languageserver-bin import-js bash-language-server


######## Install ###########
.PHONY: install-common
install-common:
	@rsync -azv $(BUILD)/ ${HOME}
	@curl -sLf https://spacevim.org/install.sh | bash

.PHONY: install-Darwin
install-Darwin: install-common

.PHONY: install-Linux
install-Linux: install-common install-fonts-Linux
	@if command -v fc-cache; then \
		fc-cache -vf > /dev/null; \
	fi
	@if command -v gconftool-2; then \
	  gconftool-2 -t bool -s /apps/gnome-terminal/profiles/Default/use_system_font '0'; \
	  gconftool-2 -t bool -s /apps/gnome-terminal/profiles/Default/scrollback_unlimited '1'; \
	  gconftool-2 -t string -s /apps/gnome-terminal/profiles/Default/font 'Monaco For Powerline 10'; \
	  gconftool-2 -t bool -s /apps/meld/use_custom_font '1'; \
	  gconftool-2 -t string -s /apps/meld/custom_font 'Monospace 10'; \
	  gconftool-2 -t int -s /apps/meld/tab_size '2'; \
	fi

.PHONY: install
install: all install-common install-$(UNAME)


######## Clean ###########
.PHONY: clean
clean:
	@rm -rf $(BUILD)

.PHONY: listfiles
listfiles:
	@$(foreach file,$(patsubst $(BUILD)/%, $(HOME)/%, $(TARGETS)),echo $(file);)

.PHONY: backup
backup: listfiles
	@mkdir -p $(BACKUPFOLDER)/{.bin,.ssh,.config,Library/{Preferences,Fonts}}
	@$(foreach file,$(patsubst $(BUILD)/%, $(HOME)/%, $(TARGETS)), rsync -azh --ignore-errors $(file) $(patsubst $(HOME)/%, $(BACKUPFOLDER)/%, $(file));)
