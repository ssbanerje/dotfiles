TARGETS += $(patsubst %, $(BUILD)/.%, SpaceVim.d editorconfig)

$(BUILD)/.SpaceVim.d: $(shell find editors/SpaceVim.d) $(BUILD)
	@cp -rf editors/SpaceVim.d $@

$(BUILD)/.%: editors/% $(BUILD)
	@cp -rf $< $@
