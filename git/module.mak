FILES := gitconfig gitignore gitattributes
TARGETS += $(patsubst %, $(BUILD)/.%, $(FILES))

$(BUILD)/.gitconfig: git/gitconfig config/git_config_db.json $(BUILD)
	@python3 generate_template.py --template-file git/gitconfig\
		--json-file config/git_config_db.json --output-dir $(BUILD)
	@mv $(BUILD)/gitconfig $(BUILD)/.gitconfig

$(BUILD)/.gitignore: $(wildcard git/gitignore/Global/*.gitignore) $(BUILD)
	@cat git/gitignore/Global/*.gitignore > $(BUILD)/.global_gitignore

$(BUILD)/.gitattributes: git/gitattributes $(BUILD)
	@cp git/gitattributes $(BUILD)/.gitattributes
