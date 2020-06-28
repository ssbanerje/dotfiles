TARGETS += $(patsubst %, $(BUILD)/.%, editorconfig $(shell find editors/SpaceVim.d -type f | sed "s/^editors\///"))

$(BUILD)/.SpaceVim.d/%: editors/SpaceVim.d/%
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp $< $@

$(BUILD)/.%: editors/%
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp $< $@
