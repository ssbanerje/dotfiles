TARGETS += $(patsubst %, $(BUILD)/.%, bashrc zshrc zshenv ackrc hushlogin npmrc)

$(BUILD)/.bashrc: shell/bashrc shell/bash.prompt.sh shell/bashrc.$(UNAME).sh shell/module.mak | $(BUILD)
	@#echo "- Creating $@"
	@cp -f shell/bashrc $(BUILD)/.bashrc
	@cat shell/bash.prompt.sh >> $(BUILD)/.bashrc
	@[ -e shell/bashrc.$(UNAME).sh  ] && cat shell/bashrc.$(UNAME).sh >> $(BUILD)/.bashrc

OH_MY_ZSH_FILES := $(patsubst %, $(CONFIG)/%, $(shell find shell/oh-my-zsh -type f -not -iwholename '*.git*' | sed "s/^shell\///"))

$(CONFIG)/oh-my-zsh/%: shell/oh-my-zsh/% shell/module.mak
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp $< $@

OH_MY_ZSH_FILES += $(patsubst %, $(CONFIG)/oh-my-zsh/custom/plugins/%, $(shell find shell/zsh-syntax-highlighting -type f -not -iwholename '*.git*' | sed "s/^shell\///") $(shell find shell/zsh-autosuggestions -type f -not -iwholename '*.git*' | sed "s/^shell\///"))

$(CONFIG)/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/%: shell/zsh-syntax-highlighting/% shell/module.mak
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp $< $@

$(CONFIG)/oh-my-zsh/custom/plugins/zsh-autosuggestions/%: shell/zsh-autosuggestions/% shell/module.mak
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp $< $@

$(BUILD)/.zshrc: shell/zshrc config/zsh_config_db.json $(OH_MY_ZSH_FILES) shell/module.mak
	@#echo "- Creating $@"
	@python3 generate_template.py --template-file shell/zshrc --json-file config/zsh_config_db.json --output-dir $(BUILD)
	@mv build/zshrc $@
	@[ -e shell/zshrc.$(UNAME).sh ] && cat shell/zshrc.$(UNAME).sh >> $@
	@[ -e shell/fzf.sh ] && cat shell/fzf.sh >> $@

$(BUILD)/.zshenv: shell/zshenv | $(BUILD) shell/module.mak
	@#echo "- Creating $@"
	@cp $< $@

$(BUILD)/.%: shell/% | $(BUILD) shell/module.mak
	@#echo "- Creating $@"
	@cp -rf $< $@

TARGETS += $(patsubst %, $(CONFIG)/%, common_settings.sh aliases.sh env.sh)

$(CONFIG)/env.sh: shell/env.sh shell/env.$(UNAME).sh shell/module.mak | $(CONFIG)
	@#echo "- Creating $@"
	@touch $@
	@[ -e shell/env.$(UNAME).sh ] && cat shell/env.$(UNAME).sh >> $@
	@[ -e shell/env.sh ] && cat shell/env.sh >> $@

$(CONFIG)/common_settings.sh: shell/common_settings.sh shell/common_settings.$(UNAME).sh shell/module.mak  $(patsubst %, $(CONFIG)/%, $(shell find shell/base16-shell -type f -not -iwholename '*.git*' | sed "s/^shell\///g")) | $(CONFIG)
	@#echo "- Creating $@"
	@cp shell/common_settings.sh $@
	@[ -e shell/common_settings.$(UNAME).sh ] && cat shell/common_settings.$(UNAME).sh >> $@

$(CONFIG)/base16-shell/%: shell/base16-shell/% shell/module.mak
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp $< $@

$(CONFIG)/aliases.sh: shell/aliases.sh shell/aliases.$(UNAME).sh shell/module.mak | $(CONFIG)
	@#echo "- Creating $@"
	@cp shell/aliases.sh $@
	@[ -e shell/aliases.$(UNAME).sh ] && cat shell/aliases.$(UNAME).sh >> $@

TARGETS += $(BUILD)/.tmux.conf
TPM_FILES := $(patsubst %, $(BUILD)/.tmux/plugins/tpm/%, $(shell find shell/tpm -type f -not -iwholename '*.git*' | sed "s/^shell\/tpm\///g"))

$(BUILD)/.tmux/plugins/tpm/%: shell/tpm/% shell/module.mak
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp $< $@

$(BUILD)/.tmux.conf: shell/tmux.conf $(TPM_FILES) shell/module.mak
	@#echo "- Creating $@"
	@cp $< $@

ifeq ($(UNAME), Darwin)
TARGETS += $(BUILD)/.tmux-osx.conf

$(BUILD)/.tmux-osx.conf: shell/tmux-osx.conf shell/module.mak
	@#echo "- Creating $@"
	@cp $< $@
endif

TARGETS += $(patsubst %, $(CONFIG)/ranger/%, rc.conf rifle.conf commands.py)

$(CONFIG)/ranger/%: shell/ranger/% shell/module.mak
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp $< $@

ifeq ($(UNAME), Linux)
TARGETS += $(BUILD)/.xinitrc

$(BUILD)/.xinitrc: shell/xinitrc | $(BUILD)
	@#echo "- Creating $@"
	@cp $< $@
endif
