FILES := gitconfig global_gitignore gitattributes
TARGETS += $(patsubst %, $(BUILD)/.%, $(FILES))

$(BUILD)/.gitconfig: git/gitconfig config/git_config_db.json | $(BUILD)
	@echo "- Creating $@"
	@python3 generate_template.py --template-file git/gitconfig\
		--json-file config/git_config_db.json --output-dir $(BUILD)
	@mv $(BUILD)/gitconfig $(BUILD)/.gitconfig

$(BUILD)/.global_gitignore: $(wildcard git/gitignore/Global/*.gitignore) | $(BUILD)
	@echo "- Creating $@"
	@cat git/gitignore/Global/*.gitignore > $(BUILD)/.global_gitignore

$(BUILD)/.gitattributes: git/gitattributes | $(BUILD)
	@echo "- Creating $@"
	@cp git/gitattributes $(BUILD)/.gitattributes
