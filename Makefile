######## Variables ###########
ROOT := $(shell pwd)
UNAME := $(shell uname)
BUILD := $(ROOT)/build
TARGETS := # This defines the targets built by "all"

######## Main build targets ###########
all: # Dependencies are set later

.PHONY: all

SUBDIRS := bin editors fonts git interp osx shell ssh
include $(addsuffix /module.mak, $(SUBDIRS))

all: $(TARGETS)

$(BUILD):
	@mkdir -p $(BUILD)

$(BUILD)/.config:
	@mkdir -p $(BUILD)/.config


######## Init ###########
init-submodules:
	@git submodule update --init --recursive

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
	@python3 -m pip install --upgrade --user 'python-language-server[all]'

init-prereqs-Darwin:
	@brew upgrade
	@brew install ctags coreutils git ack python fasd tmux\
		reattach-to-user-namespace node neovim bash-completion global blueutil
	@brew tap homebrew/cask-fonts && brew cask install font-hack-nerd-font
	@python3 -m pip install --upgrade 'python-language-server[all]' # Homebrew python not being able to deal with --user

init: init-prereqs-$(UNAME) init-submodules
	@python3 -m pip install --upgrade --user click jinja2 flake8 yapf autoflake\
		isort neovim
	@npm -g --production install remark remark-cli remark-stringify remark-frontmatter wcwidth prettier\
		javascript-typescript-langserver vscode-html-languageserver-bin import-js bash-language-server

.PHONY: init init-prereqs-Linux init-prereqs-Darwin init-submodules


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

install: all install-common install-$(UNAME)

.PHONY: install install-common install-vim install-Darwin install-Linux


######## Clean ###########
clean:
	@rm -rf $(BUILD)

listfiles:
	@$(foreach file,$(patsubst $(BUILD)/%, $(HOME)/%, $(TARGETS)),echo $(file);)

distclean:
	@$(foreach file,$(patsubst $(BUILD)/%, $(HOME)/%, $(TARGETS)),rm -rf $(file);)

.PHONY: clean distclean listfiles
