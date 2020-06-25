TARGETS += $(patsubst %, $(BUILD)/.%, bashrc zshrc zshenv ackrc hushlogin npmrc)

$(BUILD)/.bashrc: shell/bashrc shell/bash.prompt.sh shell/bashrc.$(UNAME).sh | $(BUILD)
	@echo "- Creating $@"
	@cp -f shell/bashrc $(BUILD)/.bashrc
	@cat shell/bash.prompt.sh >> $(BUILD)/.bashrc
	@[ -e shell/bashrc.$(UNAME).sh  ] && cat shell/bashrc.$(UNAME).sh >> $(BUILD)/.bashrc

$(BUILD)/.zshrc: shell/zshrc config/zsh_config_db.json | $(CONFIG)
	@echo "- Creating $@"
	@python3 generate_template.py --template-file shell/zshrc --json-file config/zsh_config_db.json --output-dir $(BUILD)
	@mv build/zshrc build/.zshrc

$(BUILD)/.zshenv: shell/zshenv | $(BUILD)
	@echo "- Creating $@"
	@cp $< $@

$(BUILD)/.%: shell/% | $(BUILD)
	@echo "- Creating $@"
	@cp -rf $< $@

TARGETS += $(patsubst %, $(CONFIG)/%, oh-my-zsh common_settings.sh aliases.sh env.sh)

$(CONFIG)/env.sh: shell/env.sh shell/env.$(UNAME).sh | $(CONFIG)
	@echo "- Creating $@"
	@cp shell/env.sh $(CONFIG)/env.sh
	@[ -e shell/env.$(UNAME).sh ] && cat shell/env.$(UNAME).sh >> $(CONFIG)/env.sh

$(CONFIG)/oh-my-zsh: $(shell find shell/oh-my-zsh) $(shell find shell/zsh-syntax-highlighting) | $(CONFIG)
	@echo "- Creating $@"
	@cp -r shell/oh-my-zsh/ $(CONFIG)/oh-my-zsh
	@mkdir -p $(CONFIG)/oh-my-zsh/custom/plugins/
	@rsync -a shell/zsh-syntax-highlighting/ $(CONFIG)/oh-my-zsh/custom/plugins/zsh-syntax-highlighting

$(CONFIG)/common_settings.sh: shell/common_settings.sh shell/common_settings.$(UNAME).sh | $(CONFIG)
	@echo "- Creating $@"
	@cp shell/common_settings.sh $(CONFIG)/common_settings.sh
	@[ -e shell/common_settings.$(UNAME).sh ] && cat shell/common_settings.$(UNAME).sh >> $(CONFIG)/common_settings.sh

$(CONFIG)/aliases.sh: shell/aliases.sh shell/aliases.$(UNAME).sh | $(CONFIG)
	@echo "- Creating $@"
	@cp shell/aliases.sh $(CONFIG)/aliases.sh
	@[ -e shell/aliases.$(UNAME).sh ] && cat shell/aliases.$(UNAME).sh >> $(CONFIG)/aliases.sh

ifeq ($(UNAME), Linux)
TARGETS += $(CONFIG)/base16-shell

$(CONFIG)/base16-shell: $(shell find shell/base16-shell) | $(CONFIG)
	@echo "- Creating $@"
	@rsync -a shell/base16-shell $(CONFIG)/
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
