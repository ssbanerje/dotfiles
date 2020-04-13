TARGETS += $(patsubst %, $(BUILD)/.%, SpaceVim.d editorconfig)

$(BUILD)/.SpaceVim.d: $(shell find editors/SpaceVim.d) | $(BUILD)
	@echo "- Creating $@"
	@cp -rf editors/SpaceVim.d $@

$(BUILD)/.%: editors/% | $(BUILD)
	@echo "- Creating $@"
	@cp -rf $< $@
