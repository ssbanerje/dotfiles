TARGETS += $(patsubst %, $(BUILD)/.%, bashrc zshrc zshenv ackrc hushlogin npmrc)

$(BUILD)/.bashrc: shell/bashrc shell/bash.prompt.sh shell/bashrc.$(UNAME).sh | $(BUILD)
	@#echo "- Creating $@"
	@cp -f shell/bashrc $(BUILD)/.bashrc
	@cat shell/bash.prompt.sh >> $(BUILD)/.bashrc
	@[ -e shell/bashrc.$(UNAME).sh  ] && cat shell/bashrc.$(UNAME).sh >> $(BUILD)/.bashrc

OH_MY_ZSH_FILES := $(patsubst %, $(CONFIG)/%, $(shell find shell/oh-my-zsh -type f -not -iwholename '*.git*' | sed "s/^shell\///"))

$(CONFIG)/oh-my-zsh/%: shell/oh-my-zsh/%
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp $< $@

OH_MY_ZSH_FILES += $(patsubst %, $(CONFIG)/oh-my-zsh/custom/plugin/%, $(shell find shell/zsh-syntax-highlighting -type f -not -iwholename '*.git*' | sed "s/^shell\///"))

$(CONFIG)/oh-my-zsh/custom/plugin/zsh-syntax-highlighting/%: shell/zsh-syntax-highlighting/%
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp $< $@

$(BUILD)/.zshrc: shell/zshrc config/zsh_config_db.json $(OH_MY_ZSH_FILES)
	@#echo "- Creating $@"
	@python3 generate_template.py --template-file shell/zshrc --json-file config/zsh_config_db.json --output-dir $(BUILD)
	@mv build/zshrc build/.zshrc

$(BUILD)/.zshenv: shell/zshenv | $(BUILD)
	@#echo "- Creating $@"
	@cp $< $@

$(BUILD)/.%: shell/% | $(BUILD)
	@#echo "- Creating $@"
	@cp -rf $< $@

TARGETS += $(patsubst %, $(CONFIG)/%, common_settings.sh aliases.sh env.sh)

$(CONFIG)/env.sh: shell/env.sh shell/env.$(UNAME).sh | $(CONFIG)
	@#echo "- Creating $@"
	@cp shell/env.sh $(CONFIG)/env.sh
	@[ -e shell/env.$(UNAME).sh ] && cat shell/env.$(UNAME).sh >> $(CONFIG)/env.sh

$(CONFIG)/common_settings.sh: shell/common_settings.sh shell/common_settings.$(UNAME).sh | $(CONFIG)
	@#echo "- Creating $@"
	@cp shell/common_settings.sh $(CONFIG)/common_settings.sh
	@[ -e shell/common_settings.$(UNAME).sh ] && cat shell/common_settings.$(UNAME).sh >> $(CONFIG)/common_settings.sh

$(CONFIG)/aliases.sh: shell/aliases.sh shell/aliases.$(UNAME).sh | $(CONFIG)
	@#echo "- Creating $@"
	@cp shell/aliases.sh $(CONFIG)/aliases.sh
	@[ -e shell/aliases.$(UNAME).sh ] && cat shell/aliases.$(UNAME).sh >> $(CONFIG)/aliases.sh

ifeq ($(UNAME), Linux)
TARGETS += $(patsubst %, $(CONFIG)/%, $(shell find shell/base16-shell -type f -not -iwholename '*.git*' | sed "s/^shell\///g"))

$(CONFIG)/base16-shell/%: shell/base16-shell/%
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp $< $@
endif

TARGETS += $(BUILD)/.tmux.conf
TPM_FILES := $(patsubst %, $(BUILD)/.tmux/plugins/tpm/%, $(shell find shell/tpm -type f -not -iwholename '*.git*' | sed "s/^shell\/tpm\///g"))

$(BUILD)/.tmux/plugins/tpm/%: shell/tpm/%
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp $< $@

$(BUILD)/.tmux.conf: shell/tmux.conf config/tmux_conf_db.json $(TPM_FILES)
	@#echo "- Creating $@"
	@python3 generate_template.py --template-file shell/tmux.conf --json-file config/tmux_conf_db.json --output-dir $(BUILD)
	@mv $(BUILD)/tmux.conf $(BUILD)/.tmux.conf
