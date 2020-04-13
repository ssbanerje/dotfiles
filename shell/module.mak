TARGETS += $(patsubst %, $(BUILD)/.%, bashrc bash_profile zshrc ackrc hushlogin npmrc)

$(BUILD)/.bashrc: shell/bashrc shell/bash.prompt.sh shell/bashrc.$(UNAME).sh | $(BUILD)
	@echo "- Creating $@"
	@cp -f shell/bashrc $(BUILD)/.bashrc
	@cat shell/bash.prompt.sh >> $(BUILD)/.bashrc
	@[ -e shell/bashrc.$(UNAME).sh  ] && cat shell/bashrc.$(UNAME).sh >> $(BUILD)/.bashrc

$(BUILD)/.bash_profile: shell/bash_profile | $(BUILD)
	@echo "- Creating $@"
	@cp -f shell/bash_profile $(BUILD)/.bash_profile

$(BUILD)/.zshrc: config/zsh_config_db.json | $(BUILD)/.config
	@echo "- Creating $@"
	@python3 generate_template.py --template-file shell/zshrc --json-file config/zsh_config_db.json --output-dir $(BUILD)
	@mv build/zshrc build/.zshrc

$(BUILD)/.%: shell/% | $(BUILD)
	@echo "- Creating $@"
	@cp -rf $< $@

TARGETS += $(patsubst %, $(BUILD)/.config/%, oh-my-zsh common_settings aliases)

$(BUILD)/.config/oh-my-zsh: $(shell find shell/oh-my-zsh) $(shell find shell/zsh-syntax-highlighting) | $(BUILD)/.config
	@echo "- Creating $@"
	@cp -r shell/oh-my-zsh/ $(BUILD)/.config/oh-my-zsh
	@mkdir -p $(BUILD)/.config/oh-my-zsh/custom/plugins/
	@rsync -a shell/zsh-syntax-highlighting/ $(BUILD)/.config/oh-my-zsh/custom/plugins/zsh-syntax-highlighting

$(BUILD)/.config/common_settings: shell/common_settings shell/common_settings.$(UNAME).sh | $(BUILD)/.config
	@echo "- Creating $@"
	@cp shell/common_settings $(BUILD)/.config/common_settings
	@[ -e shell/common_settings.$(UNAME).sh ] && cat shell/common_settings.$(UNAME).sh >> $(BUILD)/.config/common_settings

$(BUILD)/.config/aliases: shell/aliases shell/aliases.$(UNAME).sh | $(BUILD)/.config
	@echo "- Creating $@"
	@cp shell/aliases $(BUILD)/.config/aliases
	@[ -e shell/aliases.$(UNAME).sh ] && cat shell/aliases.$(UNAME).sh >> $(BUILD)/.config/aliases

ifeq ($(UNAME), Linux)
TARGETS += $(BUILD)/.config/base16-shell

$(BUILD)/.config/base16-shell: $(shell find shell/base16-shell) | $(BUILD)/.config
	@echo "- Creating $@"
	@rsync -a shell/base16-shell $(BUILD)/.config/
endif

TARGETS += $(BUILD)/.tmux.conf

$(BUILD)/.tmux/plugins: $(shell find shell/tpm)
	@echo "- Creating $@"
	@mkdir -p $(BUILD)/.tmux/plugins
	@rsync -a shell/tpm $(BUILD)/.tmux/plugins/

$(BUILD)/.tmux.conf: shell/tmux.conf config/tmux_conf_db.json $(BUILD)/.tmux/plugins
	@echo "- Creating $@"
	@python3 generate_template.py --template-file shell/tmux.conf --json-file config/tmux_conf_db.json --output-dir $(BUILD)
	@mv $(BUILD)/tmux.conf $(BUILD)/.tmux.conf
