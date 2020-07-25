######## Variables ###########
UNAME := $(shell uname)
BUILD := $(shell pwd)/build
CONFIG := $(BUILD)/.config
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
	@sudo apt-get update
	@sudo apt-get install -y global zsh ruby-dev libclang-dev clangd-9 exuberant-ctags python3-dev \
		python3-pip python3-pygments vim-nox rake tmux cmake xclip psutils rsync neovim git curl \
		silversearcher-ag python3-neovim ranger atool fzf gconf2
	@sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-9 100
	@curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
	@curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
	@echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
	@sudo apt-get update && sudo apt-get install -y nodejs yarn
	@npm config set prefix $(HOME)/.npm
	@if command -v fc-cache; then \
		mkdir -p ${HOME}/.fonts/; \
		curl -flo "/tmp/Ubuntu.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Ubuntu.zip \
			&& unzip -u /tmp/Ubuntu.zip -d ${HOME}/.fonts; \
		curl -flo "/tmp/UbuntuMono.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/UbuntuMono.zip \
			&& unzip -u /tmp/UbuntuMono.zip -d ${HOME}/.fonts; \
	fi
	@if command -v gconftool-2; then \
	  gconftool-2 -t bool -s /apps/gnome-terminal/profiles/Default/use_system_font '0'; \
	  gconftool-2 -t bool -s /apps/gnome-terminal/profiles/Default/scrollback_unlimited '1'; \
	  gconftool-2 -t string -s /apps/gnome-terminal/profiles/Default/font 'Ubuntu Nerd Font 12'; \
	  gconftool-2 -t bool -s /apps/meld/use_custom_font '1'; \
	  gconftool-2 -t string -s /apps/meld/custom_font 'UbuntuMono Nerd Font 12'; \
	  gconftool-2 -t int -s /apps/meld/tab_size '2'; \
	fi

.PHONY: init-prereqs-Darwin
init-prereqs-Darwin:
	@brew install ctags coreutils git ack ag python fasd tmux reattach-to-user-namespace node neovim \
	yarn bash-completion global blueutil ranger atool fzf
	@brew tap homebrew/cask-fonts && brew cask install font-hack-nerd-font

.PHONY: init
init: init-prereqs-$(UNAME)
	@git submodule update --init --recursive
	@python3 -m pip install --upgrade --user click jinja2 flake8 yapf autoflake isort neovim \
		python-language-server pynvim neovim-remote proselint
	@yarn global upgrade
	@yarn global add neovim remark remark-cli remark-stringify remark-frontmatter wcwidth prettier \
		vscode-html-languageserver-bin bash-language-server dockerfile-language-server-nodejs


######## Install ###########
.PHONY: install-common
install-common: all
	@rsync -azv $(BUILD)/ ${HOME}
	@curl -sLf https://spacevim.org/install.sh | bash

.PHONY: install
install: install-common


######## Clean ###########
.PHONY: clean
clean:
	@rm -rf $(BUILD)
	@find . -name ".DS_Store" -exec rm {} \;

.PHONY: listfiles
listfiles: all
	@$(foreach file,$(patsubst $(BUILD)/%, $(HOME)/%, $(TARGETS)),echo $(file);)

.PHONY: backup
backup: listfiles
	@mkdir -p $(BACKUPFOLDER)/{.bin,.ssh,.config,Library/{Preferences,Fonts}}
	@$(foreach file,$(patsubst $(BUILD)/%, $(HOME)/%, $(TARGETS)), rsync -azh --ignore-errors $(file) $(patsubst $(HOME)/%, $(BACKUPFOLDER)/%, $(file));)
