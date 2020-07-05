TARGETS += $(patsubst %, $(BUILD)/.%, curlrc gdbinit irbrc pyrc wgetrc)

$(BUILD)/.%: interp/% interp/module.mak | $(BUILD)
	@#echo "- Creating $@"
	@cp -rf $< $@
