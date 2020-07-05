TARGETS += $(patsubst %, $(BUILD)/.%, editorconfig $(shell find editors/SpaceVim.d -type f | sed "s/^editors\///"))

$(BUILD)/.SpaceVim.d/%: editors/SpaceVim.d/% editors/module.mak
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp $< $@

$(BUILD)/.%: editors/% editors/module.mak
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp $< $@
